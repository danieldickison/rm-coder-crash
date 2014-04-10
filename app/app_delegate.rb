class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    run_test
    true
  end

  def run_test
    archive = BCArchive.alloc.init
    while true
      Dispatch::Queue.concurrent.async do
        if rand < 0.1
          entry = DiskCacheEntry.alloc.initWithData(UIImagePNGRepresentation(UIImage.imageNamed('logo-bandcamp')), format:rand(10))
          archive.set(entry, block:lambda do |cached_entry|
            NSLog('archived entry %@', cached_entry)
          end)
        else
          archive.get(lambda do |entry|
            NSLog('unarchived entry %@', entry)
          end)
        end
      end
      sleep(0.1 * rand)
    end
  end
end

# The disk cache entry implements methods from the NSCoding protocol so that TMDiskCache can serialize it to disk.
class DiskCacheEntry < NSObject
    attr_reader :data, :format

    def initWithData(data, format:format)
        init
        @data = data
        @format = format
        return self
    end

    def initWithCoder(coder)
        init  # comment out this line to reduce crashiness
        @data = coder.decodeObjectForKey('data')
        @format = coder.decodeIntForKey('format')
        return self
    end

    def encodeWithCoder(coder)
        coder.encodeObject(@data, forKey:'data')
        coder.encodeInt(@format, forKey:'format')
    end

    def decode_image
        return UIImage.imageWithData(@data, scale:UIScreen.mainScreen.scale)
    end

    def description
        return "<DiskCacheEntry format:#{@format} data:#{data.length} bytes>"
    end
end
