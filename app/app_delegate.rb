class AppDelegate
  # IOS
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    if RUBYMOTION_ENV == 'test'
      MotionDataWrapper.clean_data
    end
    true
  end

  # OSX
  def applicationDidFinishLaunching(notification)
    if RUBYMOTION_ENV == 'test'
      MotionDataWrapper.clean_data
    end
    true
  end
end
