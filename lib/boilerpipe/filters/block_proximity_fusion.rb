# encoding: utf-8
module Boilerpipe::Filters
  class BlockProximityFusion
    # Fuses adjacent blocks if their distance (in blocks) does not exceed a certain limit. This
    # probably makes sense only in cases where an upstream filter already has removed some blocks.

    #MAX_DISTANCE_1 = BlockProximityFusion.new(1, false, false)
    #MAX_DISTANCE_1_SAME_TAGLEVEL = BlockProximityFusion.new( 1, false, true)
    #MAX_DISTANCE_1_CONTENT_ONLY = BlockProximityFusion.new( 1, true, false)
    #MAX_DISTANCE_1_CONTENT_ONLY_SAME_TAGLEVEL = BlockProximityFusion.new(1, true, true)

    @max_blocks_distance
    @content_only
    @same_tag_level_only

    def initialize(max_blocks_distance, content_only, same_tag_level_only)
      @max_blocks_distance = max_blocks_distance
      @content_only = content_only
      @same_tag_level_only = same_tag_level_only
    end

    def process(doc)
      text_blocks = doc.text_blocks
      return false if text_blocks.size < 2
      changes = false
      prev_block = nil
      offset = 0
      blocks_to_remove = []

      prev_block = if @content_only
                     text_blocks.find{|tb| tb.is_content? == true}
                   else
                     text_blocks.first
                   end

      return false if prev_block.nil?

      offset = text_blocks.index(prev_block)
      blocks = text_blocks[offset..-1]
      combined_blocks = blocks.delete_if do |tb|
        prev_block = tb unless tb.is_content?
        next unless tb.is_content?

        ok = true

        diff_blocks = blocks.index(tb) - blocks.index(prev_block)
        next if diff_blocks == 0
        if diff_blocks <= @max_blocks_distance
          ok = false if (prev_block.is_not_content? || tb.is_not_content?) && @content_only
          ok = false if ok && prev_block.tag_level != tb.tag_level && @same_tag_level_only
        end

        if ok
          prev_block.merge_next(tb)
          blocks_to_remove << tb
          changes = true
          true # delete current node
        else
          prev_block = tb
          false # don't delete current node
        end
      end

      doc.replace_text_blocks!(combined_blocks)
      changes
    end

  end
end
