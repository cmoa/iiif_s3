### Missing Tests
* [ ] Add explicit tests for internet-enabled configs
* [ ] Add tests for baseUriRedirect
* [ ] Implement NoMaster check
* [ ] Figure out how to optimize the image writing
* [ ] Add in the ability to skip generated directories (with override)
* [ ] Think about directory structure
* [ ] Add in preview system
* [ ] Look into bucket existance check for s3
* [ ] Add in redirect for w,h to w,
* [ ] research how to get to the actual website URL (so redirects work).
* [ ] Add in link header for images: Link: <http://iiif.example.com/server/full/full/0/default.jpg; rel="canonical", and then add "profileLinkHeader" as a feature
* [ ] Add in header for info: Link: <http://iiif.io/api/image/2/context.json>; rel="http://www.w3.org/ns/* [ ] json-ld#context"; type="application/ld+json"
* [ ] Look into Content-Disposition header


###

Redirects are only supported by the static website endpoints, which contain "s3-website". The standard S3 endpoints, such as s3.amazonaws.com, will not serve redirects. Instead, you will see the x-amz-website-redirect-location header being returned.


### Questions
* Ask about sizes vs canonical form?  Redirect?
* What does "The @context, @id and @type properties are required when the profile is dereferenced from a URI, but should not be included in the Image Information response." <http://iiif.io/api/image/2.0/#image-information>
* Ask about Sequence Description
