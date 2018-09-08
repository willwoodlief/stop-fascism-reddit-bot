class PageController < ApplicationController
  def show_settings
    @subreddit_names =  Subreddit.pluck(:subreddit_name)
    @archive_command = Setting.only_row.archiver_program
    @bads = BadSite.active.pluck(:url)
    @history = Post.order('created_at desc').limit(50).all
    @settings = Setting.only_row
  end

  def update_settings
    b_is_running = params[:is_running].blank? ? false : true
    b_dry_run = params[:dry_run].blank? ? false : true
    if params[:archive_command] === 'is'
      archive = '/usr/local/bin/archiveis'
    elsif params[:archive_command] === 'org'
      archive = '/usr/local/bin/savepagenow --accept-cache'
    else
      archive = nil
    end

    template = params[:template]
    subreddits = params[:subreddits].split("\n").map(&:strip)
    blacklist = params[:domains].split("\n").map(&:strip)
    settings = Setting.first
    settings.archiver_program = archive
    settings.template = template
    settings.is_running = b_is_running
    settings.dry_run = b_dry_run
    settings.save!

    BadSite.update_list(blacklist)
    Subreddit.update_list(subreddits)

    @subreddit_names =  Subreddit.pluck(:subreddit_name)
    @archive_command = Setting.only_row.archiver_program
    @bads = BadSite.active.pluck(:url)
    @history = Post.order('created_at desc').limit(50).all
    @settings = Setting.only_row

    render :show_settings
  end
end
