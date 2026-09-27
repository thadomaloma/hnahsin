module Audit
  class Record
    def self.call(actor:, auditable:, action:, metadata: {}, request_id: nil)
      AuditEvent.create!(
        actor: actor,
        auditable: auditable,
        action: action,
        metadata: metadata,
        request_id: request_id,
        occurred_at: Time.current
      )
    end
  end
end
