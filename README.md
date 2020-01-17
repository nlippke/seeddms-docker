# Information

Builds a docker image for seeddms (https://www.seeddms.org).

This image supports OCR processing for images and PDFs.

## How to run

`docker run --name seeddms -d -v <local>:/var/www/seeddms/data -p 8080:80 seeddms`

## Additional information

The image is base on https://github.com/ludwigprager/docker-seeddms.


