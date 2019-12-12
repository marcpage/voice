#!python3

#  scrape_general_conference_talks.py
#  Prophet's Voice
#
#  Created by Marc on 12/8/19.
#  Copyright © 2019 Resolve To Excel. All rights reserved.

# // MARK: - Imports

import hashlib
import json
import os
import re
import sys
import threading
import time
import traceback
try: import urllib2 as urllib
except: import urllib.request as urllib
try: import Queue as queue
except: import queue

# // MARK: - Constants

Log_Path = '/tmp/scrape_general_conference_talks.txt'

Church_Server = 'https://www.ChurchOfJesusChrist.org'
Root_Url = Church_Server + '/general-conference/conferences?lang=eng'
Cache_Path = os.path.join(os.environ['HOME'], 'Library', 'Caches', 'general_conference')
User_Agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3'

RootCoferenceStart = re.compile(r'<section class="all-conferences lumen-template-landing">')
RootConferenceEnd = re.compile(r'</section>')
RootConferencePattern = re.compile(r'<a href="(?P<url>[^"]+)" class="year-line__link">\s*(?P<name>\S+\s+[0-9]+)\s*</a>')

ConferenceDataStart = re.compile(r'<div class="section-wrapper lumen-layout lumen-layout--landing-3">')
ConferenceDataEnd = re.compile(r'<div class="page-footer section-wrapper lumen-layout lumen-layout--landing-3 page-footer--full-width">')
ConferenceDataSessionDivider = re.compile(r'<div class="section tile-wrapper layout--3 lumen-layout__item">')
ConferenceSessionName = re.compile(r'<span class="section__header__title">(?P<name>[^<]+)</span>')
ConferenceTalkDivider = re.compile(r'<div class="lumen-tile lumen-tile--horizontal lumen-tile--list">')
ConferenceTalkUrl = re.compile(r'<a href="(?P<url>[^"]+)" class="lumen-tile__link">')
ConferenceTalkThumbnail = re.compile(r'<img src="(?P<thumbnail_url>(https:)?//[^"]+)" alt="(?P<thumbnail_name>[^"]+)" class="lumen-image__image">')
ConferenceTalkTitle = re.compile(r'<div class="lumen-tile__title">\s*(?P<title>[^<]+)\s*</?div', re.MULTILINE)
ConferenceTalkSpeaker = re.compile(r'<div class="lumen-tile__content">(?P<speaker>[^<]+)</div>')

TalkVideoPattern = re.compile(r'<source type=video/mp4 data-width=(?P<width>[0-9]+) data-height=(?P<height>[0-9]+) data-file-size=(?P<size>[0-9]+) src=(?P<url>[^>]+)>')
TalkAudioPattern = re.compile(r'<a href="(?P<mp3_url>[^"]+\.mp3[^"]+)" title="[^"]+" class=[^>]+ download="">')
TalkAudioAlternate = re.compile(r'<source src="(?P<mp3_url>[^"]+.mp3[^"]*)">')
TalkRolePattern = re.compile(r'<p class=author-role data-aid=\S+ id=author2>(?P<role>[^<]+)</p>')
TalkContentsBegin = re.compile(r'<div class=body-block>')
TalkContentsEnd = re.compile(r'</article>')

Non_Alpha_Numeric = re.compile(r'[^A-Za-z0-9]+')
Html_Tags = re.compile(r'<[^>]+>')
Title_Tags = re.compile(r'</?(em|cite|div)>')
Year_Pattern = re.compile(r'((19|20)[0-9][0-9])')

# // MARK: - Helpers

def do_log(m):
    with open(Log_Path, 'a') as f:
        f.write("[%s] %s\n"%(time.strftime('%Y/%m/%d %H:%M:%S'), m))

def start_thread(target, *args):
    t = threading.Thread(target=target, args=args)
    t.setDaemon(True)
    t.start()
    return t

def status(s):
    sys.stderr.write(s)
    sys.stderr.flush()

def url_to_cache_path(name, s):
    hasher = hashlib.new('sha256')
    hasher.update(s.encode('utf-8'))
    return os.path.join(Cache_Path, Non_Alpha_Numeric.sub('_', name) + '_' + hasher.hexdigest())

Url_Read_Time = 0.0
Url_Read_Count = 0
def read_url(name, url, cache=True):
    try:
        if cache:
            with open(url_to_cache_path(name, url), 'r') as f: contents = f.read()
        else: raise SyntaxError()
    except:
        global Url_Read_Time
        global Url_Read_Count

        start_time = time.time()
        request = urllib.Request(url, headers={'User-Agent': User_Agent})
        contents = urllib.urlopen(request).read().decode('utf-8')
        Url_Read_Time += (time.time() - start_time)
        Url_Read_Count += 1
        #time.sleep(Url_Read_Time / Url_Read_Count) #  could be used to throttle
        with open(url_to_cache_path(name, url), 'w') as f: f.write(contents)
    return contents

def clean_url(url): return Church_Server + url.replace('&#x3D;', '=')

def clean_html(html): return Html_Tags.sub('', html)

def cleanup_dict(d):
    for key in d:
        try: d[key] = d[key].strip()
        except: pass

# // MARK: - Text Scraping Utilities

def scrape_block_contents(contents, start_pattern, end_pattern, include_marginss=False):
    parts = start_pattern.split(contents, 1)
    if len(parts) > 1:
        prefix = parts[0]
        parts = end_pattern.split(parts[1])
    else: raise SyntaxError('Need to update regex: ' + start_pattern.pattern)
    if len(parts) > 1:
        suffix = parts[-1]
        return (prefix, ''.join(parts[:-1]), suffix) if include_marginss else ''.join(parts[:-1])
    else: raise SyntaxError('Need to update regex: ' + end_pattern.pattern)
    return None

def scrape_data_list(contents, pattern):
    elements = []
    
    for match in pattern.finditer(contents):
        elements.append(match.groupdict())
    
    if not elements:
        raise SyntaxError('Need to update regex: ' + pattern.pattern)
    
    return elements

def split_data(contents, pattern):
    contents_list = pattern.split(contents)

    if not contents_list:
        raise SyntaxError('Need to upgrade regex: ' + pattern.pattern)

    return contents_list[1:] # first is empty because of split

def scrape_data(contents, pattern, update=None):
    has_data = pattern.search(contents)
    
    if not has_data:
        do_log('Could not find "' + pattern.pattern + '" in\n' + contents)
        raise SyntaxError('Need to update regex: ' + pattern.pattern)
    
    if None == update:
        update = {}
    
    update.update(has_data.groupdict())
    return update
    
# // MARK: - General Conference

def scrape_conferences(root_url):
    try:
        contents = read_url('root', root_url)
        conferences_contents = scrape_block_contents(contents, RootCoferenceStart, RootConferenceEnd)
        conferences_list = scrape_data_list(conferences_contents, RootConferencePattern)
        
        for conference in conferences_list:
            conference['url'] = clean_url(conference['url'])
            
        return conferences_list
    except:
        do_log(traceback.format_exc())
        do_log('*** Error while trying to fetch root url: ' + root_url)
        raise

def scrape_conference(name, url):
    talks = []
    
    try:
        contents = read_url(name, url)
        sessions_contents = scrape_block_contents(contents, ConferenceDataStart, ConferenceDataEnd)
        sessions_contents_list = split_data(sessions_contents, ConferenceDataSessionDivider)
        session_index = 0
        
        for session_content in sessions_contents_list:
            session_name = scrape_data(session_content, ConferenceSessionName)['name']
            talk_contents_list = split_data(session_content, ConferenceTalkDivider)
            session_index += 1
            talk_index = 0
            
            for talk_content in talk_contents_list:
                try:
                    talk_index += 1
                    has_year = Year_Pattern.search(name)
                    year = has_year.group(0) if has_year else 'XXXX'
                    month = '04' if 'april' in name.lower() else ('10' if 'october' in name.lower() else 'XX')
                    
                    talk_info = {
                        'session': session_name,
                        'conference' : name,
                        'identifier' : '%s%s%02d%02d'%(year, month, session_index, talk_index)
                    }
                    scrape_data(talk_content, ConferenceTalkUrl, talk_info)
                    talk_info['url'] = clean_url(talk_info['url'])
                    scrape_data(Title_Tags.sub('', talk_content), ConferenceTalkTitle, talk_info)
                    scrape_data(talk_content, ConferenceTalkSpeaker, talk_info)
                    try:
                        scrape_data(talk_content, ConferenceTalkThumbnail, talk_info)
                        talk_info['thumbnail_url'] = talk_info['thumbnail_url'].replace('http:', 'https:')
                    except: pass
                    cleanup_dict(talk_info)
                    
                    if talk_info.get('thumbnail_url', '').startswith('//'):
                        talk_info['thumbnail_url'] = 'https:' + talk_info['thumbnail_url']
                        
                    talks.append(talk_info)
                except:
                    do_log(traceback.format_exc())
                    do_log('*** Error processing session: ' + str(talk_info))
                    do_log(talk_content)
                    raise

    except:
        do_log(traceback.format_exc())
        do_log('*** Error while trying to fetch ' + name + ' url: ' + url)
        raise
    
    return talks

def update_talk(talk_info):
    """
    {
      "session": "Saturday Morning Session",
      "url": "https://www.ChurchOfJesusChrist.org/study/general-conference/2019/04/11soares?lang=eng",
      "title": "How Can I Understand?",
      "speaker": "Ulisses Soares",
      "thumbnail_url": "https://media.ldscdn.org/images/videos/general-conference/april-2019-general-conference/2019-04-1010-ulisses-soares-100x83-6x5-resized.jpg",
      "thumbnail_name": "Ulisses Soares"
    }
    """
    contents = read_url(talk_info['conference'] + ':' + talk_info['session'] + ':' + talk_info['title'], talk_info['url'])

    try:
        scrape_data(contents, TalkAudioPattern, talk_info)
    except: scrape_data(contents, TalkAudioAlternate, talk_info)
    talk_info['mp3_url'] = talk_info['mp3_url'].replace('http:', 'https:')

    try: scrape_data(contents, TalkRolePattern, talk_info)
    except: pass

    try:
        pass #video_list = scrape_data_list(contents, TalkVideoPattern)
        #talk_info['videos'] = {(v['width'] + 'x' + v['height']):v['url'] for v in video_list}
    except: pass
    
    try:
        pass #talk_info['contents'] = clean_html(scrape_block_contents(contents, TalkContentsBegin, TalkContentsEnd))
    except: pass
    
    return talk_info

# // MARK: - Threads

def find_talks(conference_queue, talk_queue):
    while True:
        next = conference_queue.get()

        if None == next:
            conference_queue.put(None)
            break
        
        do_log(next['name'])
        
        try:
            talks = scrape_conference(next['name'], next['url'])
            for talk in talks:
                talk_queue.put(talk)
            #status('+')
        except:
            print(traceback.format_exc())
            print("Error gettings talks: " + next['name'])
            print(next['url'])
            do_log(traceback.format_exc())
            do_log('*** Error finding talks: ' + str(next))

def update_talks(talk_queue, final_talk_queue):
    last_conference = None
    while True:
        next = talk_queue.get()
        
        if None == next:
            talk_queue.put(None)
            break

        do_log(next['conference'] + ':' + next['session'] + ':' + next['title'])
        
        if last_conference != next['conference']:
            last_conference = next['conference']
            status(last_conference + '\n')
            
        try:
            update_talk(next)
            #status('.')
        except:
            print(traceback.format_exc())
            print("Error updating talk: " + (next['conference'] + ':' + next['session'] + ':' + next['title']))
            print(next['url'])
            do_log(traceback.format_exc())
            do_log('*** Error updating talks: ' + str(next))
        final_talk_queue.put(next)

# // MARK: - Main

def main():
    do_log("STARTING RUN")
    if not os.path.isdir(Cache_Path): os.makedirs(Cache_Path)
    
    conference_queue = queue.Queue()
    raw_talk_queue = queue.Queue()
    final_talk_queue = queue.Queue()
    
    threads = [
        start_thread(find_talks, conference_queue, raw_talk_queue),
        start_thread(update_talks, raw_talk_queue, final_talk_queue),
        start_thread(update_talks, raw_talk_queue, final_talk_queue),
        start_thread(update_talks, raw_talk_queue, final_talk_queue),
    ]

    conferences_list = scrape_conferences(Root_Url)

    for conference in conferences_list: conference_queue.put(conference)

    talks = []
    
    while True:
        if conference_queue.empty() and raw_talk_queue.empty() and final_talk_queue.empty():
            time.sleep(0.100)
            if conference_queue.empty() and raw_talk_queue.empty() and final_talk_queue.empty():
                break
        
        try:
            talks.append(final_talk_queue.get(timeout=0.100))
        except queue.Empty:
            pass
    
    talks.sort(key=lambda x:x['identifier'], reverse=True)
    
    missing_thumbnails = {}
    for talk in talks:
        if talk.get('thumbnail_url', None) and talk['speaker'] not in missing_thumbnails:
            missing_thumbnails[talk['speaker']] = talk['thumbnail_url']
    
    for talk in talks:
        if not talk.get('thumbnail_url', None) and talk['speaker'] in missing_thumbnails:
            talk['thumbnail_url'] = missing_thumbnails[talk['speaker']]

    with open(sys.argv[1], 'w') as f:
        json.dump([t for t in talks if 'mp3_url' in t], f, indent=2, sort_keys=True)
    
if __name__ == '__main__': main()
