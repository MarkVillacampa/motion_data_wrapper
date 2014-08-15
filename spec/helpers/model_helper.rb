module MotionDataWrapper
  class Manager
    def clean_data
      @managedObjectContext = nil
      @managedObjectModel = nil
      @coordinator = nil
      @sqlite_path = nil
      manager = NSFileManager.defaultManager
      manager.removeItemAtURL sqlite_url, error:nil
      manager.removeItemAtURL NSURL.URLWithString(sqlite_url.absoluteString+'-shm'), error:nil
      manager.removeItemAtURL NSURL.URLWithString(sqlite_url.absoluteString+'-wal'), error:nil
    end
  end
end

module MotionDataWrapper
  class Model
    module CoreData

      module ClassMethods

        def clean_entity_description
          @_metadata = nil
        end

      end

    end
  end
end

def clean_core_data
  # We need to clean the #entity_description for every model as it is memoized from the managedObjectModel and we're cleaning that too
  App.delegate.managedObjectModel.entities.map(&:managedObjectClassName).each { |c| Kernel.const_get(c).clean_entity_description }
  MotionDataWrapper::Manager.shared.clean_data
end
