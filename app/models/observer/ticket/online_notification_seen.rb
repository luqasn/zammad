# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Observer::Ticket::OnlineNotificationSeen < ActiveRecord::Observer
  observe 'ticket'

  def after_create(record)
    _check(record)
  end

  def after_update(record)
    _check(record)
  end

  private

  def _check(record)

    # return if we run import mode
    return if Setting.get('import_mode')

    # set seen only if state has changes
    return if !record.changes
    return if record.changes.empty?
    return if !record.changes['state_id']

    # check if existing online notifications for this ticket should be set to seen
    return true if !record.online_notification_seen_state

    # set all online notifications to seen
    # send background job
    Delayed::Job.enqueue(Observer::Ticket::OnlineNotificationSeen::BackgroundJob.new(record.id, record.updated_by_id))
  end
end
