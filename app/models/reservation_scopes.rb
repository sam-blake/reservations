module ReservationScopes
  def self.included(base) # rubocop:disable MethodLength, AbcSize
    base.class_eval do
      scope :recent, ->() { order('start_date, due_date, reserver_id') }
      scope :user_sort, ->() { order('reserver_id') }
      scope :finalized, lambda {
        where('approval_status = ? OR approval_status = ?', 'auto',
              'approved')
      }
      scope :not_returned, ->() { where('checked_in IS NULL').finalized }
      scope :active, ->() { not_returned }
      # TODO: grep codebase for active and replace with not_returned or
      # figure out a better way to give the same scope two names
      scope :untouched, ->() { where('checked_out IS NULL').not_returned }
      scope :reserved, lambda {
        where('due_date >= ?', Date.current.to_time).untouched.recent
      }
      scope :checked_out, lambda {
        where('checked_out IS NOT NULL').not_returned.recent
      }
      scope :checked_out_today, lambda {
        where('checked_out >= ? and checked_out <= ?',
              Date.current.to_time.to_datetime,
              Date.current.to_time.to_datetime + 1.day).not_returned.recent
      }
      scope :checked_out_previous, lambda {
        where('checked_out < ? and due_date <= ?', Date.current.to_time,
              Date.current.to_time + 1.day).not_returned.recent
      }
      scope :overdue, lambda {
        where('due_date < ?', Date.current.to_time).checked_out
      }
      scope :returned, lambda {
        where('checked_in IS NOT NULL and checked_out IS NOT NULL').recent
      }
      scope :checked_in, ->() { returned }
      scope :returned_on_time, ->() { where('checked_in <= due_date').returned }
      scope :returned_overdue, ->() { where('due_date < checked_in').returned }
      scope :missed, lambda {
        where('due_date < ?', Date.current.to_time).untouched.recent
      }
      scope :upcoming, lambda {
        where('start_date = ?', Date.current.to_time).reserved.user_sort
      }
      scope :checkoutable, lambda {
        where('start_date <= ?', Date.current.to_time).reserved
      }
      scope :starts_on_days, lambda {
        |start_date, end_date|  where(start_date: start_date..end_date)
      }
      scope :ends_on_days, lambda {
        |start_date, end_date|  where(due_date: start_date..end_date)
      }
      scope :reserved_on_date, lambda {
        |date|  where('start_date <= ? and due_date >= ?',
                      Time.zone.parse(date.to_s),
                      Time.zone.parse(date.to_s)).finalized
      }
      scope :for_eq_model, lambda {
        |eq_model| where(equipment_model_id: eq_model.id).finalized
      }
      scope :active_or_requested, lambda {
        where('checked_in IS NULL and approval_status != ?', 'denied').recent
      }
      scope :notes_unsent, ->() { where(notes_unsent: true) }
      scope :requested, lambda {
        where('start_date >= ? and approval_status = ?',
              Date.current.to_time, 'requested').recent
      }
      scope :approved_requests, lambda {
        where('approval_status = ?', 'approved').recent
      }
      scope :denied_requests, lambda {
        where('approval_status = ?', 'denied').recent
      }
      scope :missed_requests, lambda {
        where('approval_status = ? and start_date < ?', 'requested',
              Date.current.to_time).recent
      }
      scope :for_reserver, ->(reserver) { where(reserver_id: reserver) }
      scope :reserved_in_date_range, lambda {
        |start_date, end_date| where('start_date <= ? and due_date >= ?',
                                     end_date, start_date).finalized
      }
      scope :overlaps_with_date, lambda {
        |date| where('start_date <= ? and due_date >= ?', date.to_datetime,
                     date.to_datetime)
      }
      scope :has_notes, ->() { where.not(notes: nil) }
      scope :overlaps_date_range, lambda { |start_date, end_date|
        from("(#{reserved_in_date_range(start_date, end_date).to_sql} UNION
               #{overlaps_with_date(start_date).to_sql} UNION
               #{overlaps_with_date(end_date).to_sql}) AS reservations")
      }
    end
  end
end
