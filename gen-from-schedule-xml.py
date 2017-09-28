#!/usr/bin/python3
import argparse
import subprocess
import xml.etree.ElementTree as ET
from datetime import datetime
import locale

def parse_schedule(filename):

    tree = ET.parse(filename)
    root = tree.getroot()
    events = root.find('day').find('room').findall('event')
    event_dict = { e.get('id'): e for e in events } # TODO convert to int?
    return event_dict

def generate_talk_info(event_node):

    id = event_node.get('id')
    date_string = event_node.find('date').text

    # remove colon from timezone specifier of date string
    i = date_string.rindex(':')
    date_string = date_string[:i] + date_string[i+1:]

    date = datetime.strptime(date_string, '%Y-%m-%dT%H:%M:%S%z')
    locale.setlocale(locale.LC_ALL, 'de_DE')
    formatted_date = date.strftime('%m. %B %Y')
    title = event_node.find('title').text
    persons = event_node.find('persons').findall('person')
    persons_string = ', '.join(p.text for p in persons)

    return (id, formatted_date, persons_string, title)

def run_generator(executable, event_node):

    id, formatted_date, persons_string, title = generate_talk_info(event_node)
    subprocess.check_call([executable, formatted_date, persons_string, title, id])

def main():

    parser = argparse.ArgumentParser(description='Intro/Outro Generator XML Reader')
    parser.add_argument('xmlfile', help='Schedule xml filename.')
    parser.add_argument('eventids', nargs='*', help='Event IDs for the events intros should be generated for. Defaults to all events present in schedule file if omitted.')
    parser.add_argument('--executable', metavar='E', default='./.internal-gen.sh', help='Name of Intro/Outro generator script. Defaults to "./.internal-gen.sh", which should work inside this repository.')
    args = parser.parse_args()

    event_dict = parse_schedule(args.xmlfile)

    eventids = args.eventids if args.eventids else event_dict.keys()

    for i in eventids:
        run_generator(args.executable, event_dict[i])

if __name__ == "__main__":
    main()
