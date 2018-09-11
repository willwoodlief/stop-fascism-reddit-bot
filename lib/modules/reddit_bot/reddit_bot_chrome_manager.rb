module RedditBot

  require 'selenium-webdriver'




  class ChromeManager
    attr_reader :driver

    def initialize
      # settings for selenium used in this engine
      Rails.logger.info '[Flancer] Starting Web Driver'
      Selenium::WebDriver.logger.level = :warn
      options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])

      # options.add_argument("user-data-dir=new_chrome_dir")

      @driver = Selenium::WebDriver.for(:chrome, options: options)
      @driver.manage.window.resize_to(1280, 1000)

    end

    def clean_up
      close_driver
    end

    def snapshot(url:)
      begin
      seconds_to_wait = 10
      raise "Driver not initiated" if @driver.blank?
      driver = @driver
      Rails.logger.info '[Chrome Manager] Going to ' + url
      driver.get(url)
      wait = Selenium::WebDriver::Wait.new(timeout: seconds_to_wait) # seconds

      begin
        wait.until {driver.execute_script("return document.readyState;") == 'complete'}

        width  = driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
        height = driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
        width = 1600 if width.to_i > 1600
        height = 7900 if height.to_i > 7900
        @driver.manage.window.resize_to(width + 100, height + 100)
        dets = take_snapshot
        return dets[:snapshot]

      rescue Selenium::WebDriver::Error::TimeOutError
        Rails.logger.error '[Chrome Manager] ' + "Could not load". url
        raise "Could not load in chrome after #{seconds_to_wait} seconds". url
      end
      rescue => e
        log_browser_info
        raise e
       end
    end

    def close_driver
      Rails.logger.info '[Flancer] ' + "Closing Driver and making it blank"
      @driver.quit unless @driver.blank?
      @driver = nil
    end

    def take_snapshot(stem: 'snapshot',timestamp:nil)
      return {snapshot: nil, html: nil} if @driver.blank?
      timestamp = Time.now.to_i if timestamp.nil?
      page_html = @driver.page_source
      name = "/tmp/#{timestamp}_#{stem}"
      snapshot_file_name = name + ".png"
      html_file_name = name + ".html"
      File.open(html_file_name, "w").write(page_html)
      #driver.full_screenshot(snapshot_file_name)
      @driver.save_screenshot(snapshot_file_name)
      return {snapshot: snapshot_file_name, html:html_file_name }
    end



    def log_browser_info
      return if @driver.blank?
      Rails.logger.info '[Flancer] [Browser Errors and Warnings] ' + "browser errors"
      log_entries = @driver.manage.logs.get :browser
      log_entries.each do |k, v|
        Rails.logger.info '[Flancer][Browser Errors and Warnings] ' + k.to_s + '=>' + v.to_s;
      end
    end
  end

end