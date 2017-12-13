# Python 3.5

# 1. Visit https://api.imgur.com/oauth2/addclient
# 2. Fill in Application Name, any url for Authorization Callback URL, Email, and Description.
# 3. Set Authorization Type to Anonymous.
# 4. Fill in client_id below
client_id = ""

###########
# Do not edit below.
###########

from urllib.request import Request, urlopen
import json
import os
import sys

# Get list of image URLs from the album.
def retrieve_image_urls(album_hash):
  # Imgur anonymous API calls authorized with client ID.
  url = "https://api.imgur.com/3/album/{0}/images".format(album_hash)
  req = Request(url, headers={'Authorization': "CLIENT-ID " + client_id})
  
  with urlopen(req) as response:
    # API response is a list named "data" of images.
    out = response.read().decode('utf-8')
    json_out = json.loads(out)
    image_list = json_out['data']
    
    # Image data has property "link" with a url to the individual image in it.
    image_urls = []
    for i, image_data in enumerate(image_list):
      image_urls.append(image_data['link'])
    
    return image_urls



# Download images from list of URLs
def download_images(album_hash, url_list):
  # Store files in a directory named "Album - ALBUM_HASH" for easy separation.
  album_dir = '.\\Album - {0}\\'.format(album_hash)
  
  # Create directory if it doesn't exist.
  if not os.path.exists(album_dir):
    os.makedirs(album_dir)
  
  for i, image_url in enumerate(url_list):
    # Filenames are "# - IMAGE_HASH" from 1 to number of images in album.
    filename = '{0} - {1}'.format(i + 1, image_url[image_url.rfind('/') + 1:])
    
    # Request image and download.
    req = urlopen(image_url)
    with open(album_dir + filename, 'wb') as out_file:
      print(filename, image_url)
      out_file.write(req.read())



if __name__ == '__main__':
  if len(sys.argv) < 2:
    print("\n\nPlease supply album ID from the URL when launching.")
    print("Example: python ImgurAlbumDownloader.py KtiYY\n\n")
    sys.exit()
  
  album_hash = sys.argv[1]
  image_urls = retrieve_image_urls(album_hash)
  download_images(album_hash, image_urls)