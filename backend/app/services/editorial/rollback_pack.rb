module Editorial
  class RollbackPack
    def self.call(source_pack:, new_version:, actor:, request_id: nil)
      raise Error, "source pack must be published" unless source_pack.status_published?

      PublishPack.call(
        pack_version: new_version,
        actor: actor,
        revisions: source_pack.content_revisions.includes(:content_item, :review_decisions),
        rollback_of: source_pack,
        request_id: request_id
      )
    end
  end
end
