module App
  module_function

  def delegate
    UIApplication.sharedApplication.delegate
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
