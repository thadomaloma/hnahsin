class AuditEvent < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, :occurred_at, presence: true

  def readonly?
    persisted? || super
  end
end
