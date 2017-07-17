# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Observer::Ticket::Article::FillupFromGeneral < ActiveRecord::Observer
  observe 'ticket::_article'

  def before_create(record)
    # return if we run import mode
    return if Setting.get('import_mode')

    # only do fill of from if article got created via application_server (e. g. not
    # if article and sender type is set via *.postmaster)
    return if ApplicationHandleInfo.current.split('.')[1] == 'postmaster'

    # set from on all article types excluding email|twitter status|twitter direct-message|facebook feed post|facebook feed comment
    return if !record.type_id
    type = Ticket::Article::Type.lookup(id: record.type_id)
    return if type['name'] == 'email'

    # from will be set by channel backend
    return if type['name'] == 'twitter status'
    return if type['name'] == 'twitter direct-message'
    return if type['name'] == 'facebook feed post'
    return if type['name'] == 'facebook feed comment'

    if type.name == 'web' && !record.ticket.article_count
        # set article creator to customer_id if this is the first article in the ticket
        record.created_by_id = record.ticket.customer_id
    end

    return if !record.created_by_id
    user = User.find(record.created_by_id)
    if type.name == 'web'
      record.from = "#{user.firstname} #{user.lastname} <#{user.email}>"
      return
    end
    record.from = "#{user.firstname} #{user.lastname}"
  end
end
