module App
  module_function

  def delegate
    if Object.const_defined?("UIApplication")
      UIApplication.sharedApplication.delegate
    else
      NSApplication.sharedApplication.delegate
    end
  end

  def name
    info_plist['CFBundleDisplayName']
  end

  def info_plist
    NSBundle.mainBundle.infoDictionary
  end

  def documents_path
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
  end
end
