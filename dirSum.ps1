import os
import requests
import json
import csv
import time
import random
import argparse
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse, unquote
from concurrent.futures import ThreadPoolExecutor

def sanitize_filename(filename):
    """Remove invalid characters from filenames and directory names."""
    return "".join(c for c in filename if c.isalnum() or c in (" ", "_", "-", ".")).rstrip()

def get_links(url, visited, base_domain):
    """Fetch all links from the webpage recursively, avoiding duplicate visits and external links."""
    if url in visited:
        return [], "Untitled"
    
    visited.add(url)
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"Error fetching URL: {e}")
        return [], "Untitled"
    
    soup = BeautifulSoup(response.text, 'html.parser')
    links = {urljoin(url, a['href']): a.text.strip() for a in soup.find_all('a', href=True) if a['href'].startswith(('http', '/'))}
    
    # Filter only links belonging to the base domain
    filtered_links = {link: text for link, text in links.items() if base_domain in urlparse(link).netloc}
    
    return filtered_links, soup.title.string if soup.title else "Untitled"

def is_valid_file(link, base_domain, valid_extensions):
    """Check if the link belongs to the same domain and has a valid file extension."""
    parsed_link = urlparse(link)
    if base_domain not in parsed_link.netloc:
        return False
    
    return any(link.lower().endswith(ext) for ext in valid_extensions)

def download_file(url, filename, page_path, outDir):
    """Download the file from the given URL and save it using the anchor text as the filename inside a structured subdirectory."""
    try:
        time.sleep(random.uniform(1, 5))  # Introduce random delay to mimic human behavior
        response = requests.get(url, stream=True)
        response.raise_for_status()
    
        filename = sanitize_filename(unquote(filename)) or sanitize_filename(unquote(os.path.basename(urlparse(url).path)))
        if not filename:
            filename = "downloaded_file"
        
        file_ext = os.path.splitext(urlparse(url).path)[1]
        if not filename.endswith(file_ext):
            filename += file_ext
        
        page_dir = os.path.join(outDir, *page_path.split("/"))
        os.makedirs(page_dir, exist_ok=True)
        file_path = os.path.join(page_dir, filename)
        
        with open(file_path, 'wb') as file:
            for chunk in response.iter_content(1024):
                file.write(chunk)
        print(f"Downloaded: {file_path}")
        return file_path
    except requests.RequestException as e:
        print(f"Failed to download {url}: {e}")
        return None

def crawl_site(start_url, base_domain, outDir, valid_extensions, visited, log_data, path=""):
    """Recursively scan a website for downloadable files and record their locations."""
    try:
        links, page_title = get_links(start_url, visited, base_domain)
    except Exception as e:
        log_data.append({"url": start_url, "title": "FAILED", "error": str(e)})
        return
    
    sanitized_title = sanitize_filename(page_title)
    page_path = os.path.join(path, sanitized_title) if sanitized_title else path
    
    file_links = {link: name for link, name in links.items() if is_valid_file(link, base_domain, valid_extensions)}
    page_links = [link for link in links if link not in file_links]
    
    with ThreadPoolExecutor(max_workers=5) as executor:
        downloaded_files = list(executor.map(lambda item: download_file(item[0], item[1], page_path, outDir), file_links.items()))
    
    log_data.append({"url": start_url, "title": page_title, "files_downloaded": downloaded_files})
    
    for page_url in page_links:
        if page_url not in visited:
            crawl_site(page_url, base_domain, outDir, valid_extensions, visited, log_data, page_path + "/" + sanitize_filename(urlparse(page_url).path.strip("/")))

def save_log(log_data, log_format, outDir):
    """Save the collected log data in JSON or CSV format."""
    log_file = os.path.join(outDir, f"download_log.{log_format}")
    if log_format == "json":
        with open(log_file, "w", encoding="utf-8") as f:
            json.dump(log_data, f, indent=4)
    elif log_format == "csv":
        with open(log_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["url", "title", "files_downloaded"])
            writer.writeheader()
            for entry in log_data:
                writer.writerow(entry)
    print(f"Log saved as {log_file}")

def main():
    """Parse command-line arguments and initiate the website crawl."""
    parser = argparse.ArgumentParser(prog="SiteFileFetch", description="SiteFileFetch: A script to recursively download files from a website and log them.")
    parser.add_argument("url", help="URL of the website to scan for files.")
    parser.add_argument("--outDir", default="downloads", help="Directory to save downloaded files.")
    parser.add_argument("--log_format", choices=["json", "csv"], default="json", help="Format for the log file (json or csv).")
    parser.add_argument("--extensions", nargs="+", default=[
        '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.mp3', '.mp4', '.avi', '.mov'
    ], help="List of file extensions to download.")
    
    args = parser.parse_args()
    
    os.makedirs(args.outDir, exist_ok=True)
    base_domain = urlparse(args.url).netloc
    
    visited = set()
    log_data = []
    crawl_site(args.url, base_domain, args.outDir, args.extensions, visited, log_data)
    save_log(log_data, args.log_format, args.outDir)

if __name__ == "__main__":
    main()
