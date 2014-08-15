class AppDelegate
  include MotionDataWrapper::Delegate

  # IOS
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    if RUBYMOTION_ENV == 'test'
      MotionDataWrapper.clean_core_data
    end
    true
  end

  # OSX
  def applicationDidFinishLaunching(notification)
    if RUBYMOTION_ENV == 'test'
      MotionDataWrapper.clean_core_data
    end
    true
  end
end
