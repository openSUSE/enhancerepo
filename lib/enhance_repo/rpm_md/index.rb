
require 'enhance_repo/rpm_md/resource'

module EnhanceRepo
  module RpmMd

    # represents the repomd index
    class Index
      attr_accessor :products, :keywords
      attr_reader :log
      attr_accessor :resources
      
      # constructor
      # log logger object
      def initialize(log=Logger.new('enhancerepo'))
        @log = log
        @resources = []
      end
      
      # add a file resource. Takes care of setting
      # all the metadata.
      
      def add_file_resource(abspath, path, type=nil)
        r = Resource.new
        r.type = type
        # figure out the type of resource
        # the extname to remove is different if it is gzipped
        ext = File.extname(path)
        base = File.basename(path, ext)

        # if it was gzipped, repeat the operation
        # to get the real basename
        if ext == '.gz'
          ext = File.extname(base)
          base = File.basename(base, ext)
        end
        
        r.type = base if r.type.nil?
        r.location = abspath
        r.timestamp = File.mtime(path).to_i.to_s
        r.checksum = Digest::SHA1.hexdigest(File.new(path).read)
        r.openchecksum = r.checksum
        if File.extname(path) == '.gz'
          # we have a different openchecksum
          r.openchecksum = Digest::SHA1.hexdigest(Zlib::GzipReader.new(File.new(path)).read)
        end
        add_resource(r)
        
      end

      # add resource
      # any resource of the same location
      # is overwritten
      def add_resource(r)
        # first check if this resource is already in
        # if yes then override it
        if (index = @resources.index(r)).nil?
          # add it
          @resources << r
        else
          # replace it
          log.warn("Resource #{r.location} already exists. Replacing.")
          @resources[index] = r
        end
      end
      
      # read data from a file
      def read_file(file)
        doc = REXML::Document.new(file)
        doc.elements.each('repomd/data') do |datael|
          resource = Resource.new
          resource.type = datael.attributes['type']
          datael.elements.each do |attrel|
            case attrel.name
            when 'location'
              resource.location = attrel.attributes['href']
            when 'checksum'
              resource.checksum = attrel.text
            when 'timestamp'
              resource.timestamp = attrel.text
            when 'open-checksum'
              resource.openchecksum = attrel.text
            else
              raise "unknown tag #{attrel.name}"
            end # case
          end # iterate over data subelements
          add_resource(resource)
        end # iterate over data elements
      end
      
      # write the index to xml file
      def write(file)
        builder = Builder::XmlMarkup.new(:target=>file, :indent=>2)
        builder.instruct!
        xml = builder.repomd('xmlns' => "http://linux.duke.edu/metadata/repo") do |b|
          @resources.each do |resource|
            b.data('type' => resource.type) do |b|
              b.location('href' => resource.location)
              b.checksum(resource.checksum, 'type' => 'sha')
              b.timestamp(resource.timestamp)
              b.tag!('open-checksum', resource.openchecksum, 'type' => 'sha')
            end
          end
          
        end #builder
        
      end
      
    end

    
  end

end
