[![Build Status](https://travis-ci.org/bitflingr/thumby.svg?branch=master)](https://travis-ci.org/bitflingr/thumby)
[![codecov](https://codecov.io/gh/bitflingr/thumby/branch/main/graph/badge.svg)](https://codecov.io/gh/bitflingr/thumby)

## What?

A simple image resizer using Dragonfly, Sinatra and a few beers.

This app is meant to be a tool for creating thumbnails. You can adjust the width and height along with a Gravity specified with any image url on the interewebz.  There is no database backend so no need to worry about \*SQL backends.  The cache-control headers, imagemagick binary paths and encryption key is configurable in the application config.

![Sample image](/public/img/screen_shot1.png)

Thumby does not store any of the images, it will always fetch the image from the requested url every time, so you should think about tossing varnish or some other caching teir in front of this.  This was on purpose so if you needed to refresh the image from origin.

## Config?

In config/ copy thumby.yaml-sample to thumby.yaml.

    :preview_server: http://localhost:4567
    :thumby_hostnames:
      - 'thumby.com'
      - 'thumby.net'
    :options:
      :convert_command: /usr/local/bin/convert
      :identify_command: /usr/local/bin/identify
      :cache_duration: 86400
      :encryption_key: CHANGE_THIS_KEY
      :encryption_iv:  CHANGE_THIS_TOO
      :gif_mode:  single    # single or animated.  single will select the first frame in a gif.
      :blur_mode: disabled
      :max_size:  2000

#### thumby_hostnames:
That is just used to link the splash page.


## Creating Thumbnails?

Copy + Paste the image url from the customer into the _URL_ input field.  Input a size that you would like to have in the following format, \<width\>x\<height\>.  Then select a _Gravity_ to pull the image one direction or another.  "Center" is the default.

You can also select:

* NorthWest
* North
* NorthEast
* West
* East
* SouthWest
* South
* SouthEast

![Sample image 2](/public/img/screen_shot2.png)

## URL Format

For those who care the url for generating the thumbnail is as follows.

	http://thumby.example.com/t/<size>/<Gravity>/?url=<Customer's image url>

A new feature added is to leave out the Gravity in the url.  This will tell Thumby to use Center Gravity unless the image is a portrait, then in which case  will set the Gravity North.

	http://thumby.example.com/t/<size>/?url=<Customer's image url>

Url-safe base64 encoded url's using '-' instead of '+' and '\_' instead of '/'.

    http://thumby.example.com/t/<size>/<Gravity>/aHR0cDovL2ltYWdlcy5uYXRpb25hbGdlb2dyYXBoaWMuY29tL3dwZi9tZWRpYS1saXZlL3Bob3Rvcy8wMDAvMDA0L2NhY2hlL2FmcmljYW4tZWxlcGhhbnRfNDM1XzYwMHg0NTAuanBn

Url-safe base64 encoded AES128 encrypted string (That's a mouth full!) with a salt parameter.  The client making this call would require the same crypto key that is set in the thumby.yaml config under :encryption\_key.

    http://thumby.example.com/t/e/bGQHYjz4gK6KUBdfgfjijMER8hGYoCpro7JBuG3gSsi0yNfXppMdQmT2_z1D3AVD31VAAlTonfz6reoG8AwsJKA6_5ErhEoUlLUex5MGatGCP59pI1aScksrU6znKeZWZg9JG4yR5EV9YuoebDqR29hb0Jr0B-8xW5-Cc0TsUaA=?salt=25575e0d54e54bc2



## What's this built from?

* Ruby 2.3.3
* [Sinatra](http://sinatrarb.com)
* [Dragonfly gem](https://github.com/markevans/dragonfly)
* Imagemagick
* [Unicorn](http://unicorn.bogomips.org/) + [Raindrops](http://raindrops.bogomips.org/) :)


## Contact?

Jarrett Irons / <jarrett.irons@gmail.com>


## Todo

* Add AWS Recognition support for face detection.
* Possibly add OpenCV.
* Possibly cache images locally on server for even faster response from origin. Currently using Nginx proxy\_cache but you can also use Varnish.
