module MotionDataWrapper
  module Delegate

    def managedObjectContext
      MotionDataWrapper::Manager.shared.managedObjectContext
    end

    def managedObjectModel
      MotionDataWrapper::Manager.shared.managedObjectModel
    end

    def persistentStoreCoordinator
      MotionDataWrapper::Manager.shared.persistentStoreCoordinator
    end

    def sqlite_store_name
      MotionDataWrapper::Manager.shared.sqlite_store_name
    end

    def sqlite_url
      MotionDataWrapper::Manager.shared.sqlite_url
    end

    def sqlite_path
      MotionDataWrapper::Manager.shared.sqlite_path
    end

    def sqlite_path=(path)
      MotionDataWrapper::Manager.shared.sqlite_path = path
    end

    def persistent_store_options
      MotionDataWrapper::Manager.shared.persistent_store_options
    end

    def clean_data
      MotionDataWrapper::Manager.shared.persistent_store_options
    end

  end
end
