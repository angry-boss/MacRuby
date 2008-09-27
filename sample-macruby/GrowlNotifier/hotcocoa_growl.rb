require 'hotcocoa'

class Growl < NSObject
  include HotCocoa
  
  GROWL_IS_READY = "Lend Me Some Sugar; I Am Your Neighbor!"
  GROWL_NOTIFICATION_CLICKED = "GrowlClicked!"
  GROWL_NOTIFICATION_TIMED_OUT = "GrowlTimedOut!"
  GROWL_KEY_CLICKED_CONTEXT = "ClickedContext"
  
  PRIORITIES = {
    :emergency =>  2,
    :high      =>  1,
    :normal    =>  0,
    :moderate  => -1,
    :very_low  => -2,
  }
  
  def register(app_name, notifications, default_notifications=nil, icon=nil)
    @app_name = app_name
    @app_icon = icon || NSApplication.sharedApplication.applicationIconImage
    @notifications = notifications
    @default_notifications = default_notifications || notifications
    register_to_growl!
  end
  
  def notify(name, title, desc, options={})
    dic = {
      :NotificationName => name,
      :NotificationTitle => title,
      :NotificationDescription => desc,
      :NotificationPriority => PRIORITIES[options[:priority]] || options[:priority] || 0,
      :ApplicationName => @app_name,
      :ApplicationPID => pid,
    }
    dic[:NotificationIcon] = options[:icon].TIFFRepresentation if options[:icon]
    dic[:NotificationSticky] = 1 if options[:sticky]
    
    context = {}
    context[:user_click_context] = options[:click_context] if options[:click_context]
    dic[:NotificationClickContext] = context unless context.empty?
    
    notification :distributed => true, :name => :GrowlNotification, :info => dic
  end
  
  private
  
  def pid
    NSProcessInfo.processInfo.processIdentifier.to_i
  end
  
  def register_to_growl!
    on_notification(:distributed => true, :named => GROWL_IS_READY) do |n|
      register_to_growl!
    end

    on_notification(:distributed => true, :named => "#{@app_name}-#{pid}-#{GROWL_NOTIFICATION_CLICKED}") do |n|
      puts '@@@ on clicked'
    end

    on_notification(:distributed => true, :named => "#{@app_name}-#{pid}-#{GROWL_NOTIFICATION_TIMED_OUT}") do |n|
      puts '@@@ on timed out'
    end
  
    dic = {
      :ApplicationName => @app_name,
      :ApplicationIcon => @app_icon.TIFFRepresentation,
      :AllNotifications => @notifications,
      :DefaultNotifications => @default_notifications
    }
    notification :distributed => true, :name => :GrowlApplicationRegistrationNotification, :info => dic
  end
end
