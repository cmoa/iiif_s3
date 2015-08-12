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
  end
end