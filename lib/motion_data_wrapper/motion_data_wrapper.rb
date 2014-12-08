module MotionDataWrapper
  class << self
    def managedObjectContext
      @@managedObjectContext ||= begin
        context = NSManagedObjectContext.alloc.initWithConcurrencyType(NSMainQueueConcurrencyType)
        context.undoManager = nil
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.parentContext = rootManagedObjectContext
        context
      end
    end

    def rootManagedObjectContext
      @@rootManagedObjectContext ||= begin
        context = NSManagedObjectContext.alloc.initWithConcurrencyType(NSPrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.undoManager = nil
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context
      end
    end

    def managedObjectModel
      @@managedObjectModel ||= begin
        model = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle]).mutableCopy

        model.entities.each do |entity|
          entity.setManagedObjectClassName(entity.name)
        end
        model
      end
    end

    def persistentStoreCoordinator
      @@persistentStoreCoordinator ||= begin
        coordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(managedObjectModel)
        error_ptr = Pointer.new(:object)
        unless coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqlite_url, options: persistent_store_options, error: error_ptr)
          raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
        end
        coordinator
      end
    end

    def sqlite_store_name
      app_name
    end

    def app_name
      NSBundle.mainBundle.infoDictionary.objectForKey('CFBundleDisplayName')
    end

    def sqlite_url
      if Object.const_defined?("UIApplication")
        NSURL.fileURLWithPath(sqlite_path)
      else
        error_ptr = Pointer.new(:object)
        unless support_dir = NSFileManager.defaultManager.URLForDirectory(NSApplicationSupportDirectory, inDomain: NSUserDomainMask, appropriateForURL: nil, create: true, error: error_ptr)
          raise "error creating application support folder: #{error_ptr[0]}"
        end
        support_dir = support_dir.URLByAppendingPathComponent("#{app_name}")
        Dir.mkdir(support_dir.path) unless Dir.exists?(support_dir.path)
        support_dir.URLByAppendingPathComponent("#{sqlite_store_name}.sqlite")
      end
    end

    def sqlite_path
      @@sqlite_path ||= File.join(documents_path, "#{sqlite_store_name}.sqlite")
    end

    def documents_path
      @@documents_path ||= if Object.const_defined?("UIApplication")
          NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
        else
          NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true)[0]
        end
    end

    def persistent_store_options
      { NSMigratePersistentStoresAutomaticallyOption => true, NSInferMappingModelAutomaticallyOption => true }
    end

    def clean_data
      # We need to clean the #entity_description for every model as it is memoized from the managedObjectModel and we're cleaning that too
      MotionDataWrapper.managedObjectModel.entities.map(&:managedObjectClassName).each { |c| Kernel.const_get(c).clean_entity_description }

      @@managedObjectContext = nil
      @@rootManagedObjectContext = nil
      @@managedObjectModel = nil
      @@persistentStoreCoordinator = nil
      manager = NSFileManager.defaultManager
      manager.removeItemAtURL sqlite_url, error:nil
      manager.removeItemAtURL NSURL.URLWithString(sqlite_url.absoluteString+'-shm'), error:nil
      manager.removeItemAtURL NSURL.URLWithString(sqlite_url.absoluteString+'-wal'), error:nil
    end
  end
end

MDW = MotionDataWrapper unless defined?(MDW)
