from crawler.crawler import *
import sys
if __name__ == '__main__':
    crawler = Crawler()
    crawler.clean_files(sys.argv[1])
    crawler.running(sys.argv[1], sys.argv[2], ['reentrancy'])