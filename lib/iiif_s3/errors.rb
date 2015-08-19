module IiifS3

  #
  # Module Error collects standard errors for th IiifS3 library.
  module Error

    # Class BlankCSV indicates that a provided CSV has no data.
    class BlankCSV < StandardError; end

    # Class InvalidCSV indicates that there is something wrong with the provided CSV.
    class InvalidCSV < StandardError; end

    # Class InvalidCSV indicates that there is something wrong with the provided Image Data.
    class InvalidImageData < StandardError; end

    # Class NoMasterError indicates that all of the images in a collection are secondary images.
    class NoMasterError < StandardError; end

    # Class BadAmazonCredentials indicates that something was wrong with the Amazon login information.
    class BadAmazonCredentials < StandardError; end

    class MissingCollectionName < StandardError; end

  end
end