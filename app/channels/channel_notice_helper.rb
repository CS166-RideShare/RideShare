module ChannelNoticeHelper
  def destroy_notice(data)
    Notice.destroy data['notice_id']
  end
end
