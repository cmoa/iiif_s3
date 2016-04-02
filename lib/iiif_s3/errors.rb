module IiifS3

  #
  # Module Error collects standard errors for th IiifS3 library.
  module Error

    # Class BlankCSV indicates that a provided CSV has no data.
    class BlankCSV < StandardError; end

    # Class InvalidCSV indicates that there is something wrong with the provided CSV.
    class InvalidCSV < StandardError; end

    # Class BadAmazonCredentials indicates that something was wrong with the Amazon login information.
    class BadAmazonCredentials < StandardError; end

    # Class MissingCollectionName indicates that the collection provided did not have a label.
    class MissingCollectionName < StandardError; end

    # Class NotACollection indicates that the object provided was not a sc:Collection.
    class NotACollection < StandardError; end
 
    # Class NotAManifest indicates that the object provided was not a sc:Manifest.
    class NotAManifest < StandardError; end
    
    # Class InvalidCSV indicates that there is something wrong with the provided Image Data.
    class InvalidImageData < StandardError; end

    # Class InvalidViewingDirection indicates that the direction provided was not a valid viewing direction.
    class InvalidViewingDirection < InvalidImageData; end
    
    # Class MultiplePrimaryImages indicates that multiple images were tagged as primary for a given manifest.
    class MultiplePrimaryImages < InvalidImageData; end

    # Class NoMasterError indicates that all of the images in a collection are secondary images.
    class NoMasterError < InvalidImageData; end
  end
end