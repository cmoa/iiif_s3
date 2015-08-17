* [X] Add in "cors" as a feature
* [X] Add in "sizeByWhListed" as a feature
* [X] Add PDF support

* [ ] Generate intermediate json files for the sub-components
* [ ] Make the project respect the .json/no .json config
* [ ] Document the configuration object
* [ ] Stub out file writing for the tests
* [ ] Figure out how to optimize the image writing
* [ ] Add in the ability to skip generated directories (with override)
* [ ] Add in auto-load of paths?
* [ ] Think about directory structure
* [ ] Add in preview system
* [ ] Implement NoMaster check
* [ ] Implement test for image data without master
* [ ] Acutally delete temp files
* [ ] Look into bucket existance check for s3
* [ ] Add explicit tests for internet-enabled configs
* [ ] Add in redirect for w,h to w,
* [ ] Add in redirect (303) from image.info ID to the actual JSON doc, and then add "baseUriRedirect" as a feature
* [ ] Add in URI Encoding check for IDs
* [ ] Add in link header for images: Link: <http://iiif.example.com/server/full/full/0/default.jpg; rel="canonical", and then add "profileLinkHeader" as a feature
* [ ] Add in header for info: Link: <http://iiif.io/api/image/2/context.json>; rel="http://www.w3.org/ns/* [ ] json-ld#context"; type="application/ld+json"
* [ ] Look into Content-Disposition header


### Questions
* Ask about sizes vs canonical form?  Redirect?
* What does "The @context, @id and @type properties are required when the profile is dereferenced from a URI, but should not be included in the Image Information response." <http://iiif.io/api/image/2.0/#image-information>

