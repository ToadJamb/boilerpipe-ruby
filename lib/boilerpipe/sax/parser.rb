require 'nokogiri'
require 'set'

class Parser < Nokogiri::XML::SAX::Document
  ANCHOR_TEXT_START = "$\ue00a<"
  ANCHOR_TEXT_END = ">\ue00a$"

  def initialize
    @label = []
    @tag_actions = {}
    @tag_level = 0
    @sb_last_was_whitespace = false
    @current_contained_text_elements = Set.new
    @text_buffer = ''
    @token_buffer = ''
    @text_element_idx = 0
    @offsetBlocks = 0
	end

  def start_element(name, attrs = [])
    puts "start element #{name}"
    @label << nil

    tag_action = @tag_actions[name]
    if tag_action
			@tag_level += 1 if tag_action.changes_tag_level?
      @flush = tag_action.start(self, name, attrs) | @flush
		else
      @tag_level += 1
      @flush = true
		end

    @last_event = :START_TAG
    @last_start_tag = name
  end

  def characters(string)
    @text_element_idx += 1
    if @flush
      flush_block
    end

    return if @in_ignorable_element != 0
    return if string.empty?

    # replace all whitespace with simple space
    string = string.gsub(/\s+/, ' ')

    # trim whitespace
    started_with_whitespace = string  =~ /^\s/
    ended_with_whitespace = string  =~ /\s$/
    string = string.strip

    #  add a single space if the block was only whitespace
    if string.empty?
      append_space
      @last_event = :WHITESPACE
      return
    end

    # set block levels
    @block_tag_level = @tag_level if @block_tag_level == -1

    append_space if started_with_whitespace
    append_text(string)
    append_space if ended_with_whitespace

    @last_event = :CHARACTERS
    @current_contained_text_elements << @text_element_idx
  end

  def end_element(name)
    puts "end element #{name}"
    tag_action = @tag_actions[name]
    if tag_action
      @flush = tag_action.end(self, name) | @flush
    else
      @flush = true
    end

    @tag_level -= 1 if tag_action.nil? || tag_action.changes_tag_level?
    flush_block if @flush

    @last_event = :END_TAG
    @last_end_tag = name
    @label.pop
  end

  def flush_block
    @flush = false
    if in_body == 0
      title = @token_buffer.strip if 'TITLE'.casecmp?(@last_start_tag)
      clear_buffers
      return
    end

    # clear out if empty  or just a space
    length = @token_buffer.size
    case length
    when 0
      return
    when 1
      if @sb_last_was_whitespace
        clear_buffers
      end
      return
    end

    tokens = UnicodeTokenizer.tokenize(@token_buffer)
    tokens.each do |token|
      if ANCHOR_TEXT_START == token
        @in_anchor_text = true
      elsif ANCHOR_TEXT_END == token
        @in_anchor_text = false
      elsif is_word?(token)
        num_tokens += 1
        num_words += 1
        num_words_current_line += 1
        num_linked_words += 1 if @in_anchor_text
        token_length = token.size
        current_line_length += token_length + 1
        if current_line_length > max_line_length
          num_wrapped_lines += 1
          current_line_length = token_length
          num_words_current_line = 1
        end
      else
        num_tokens += 1
      end
    end

    return if num_tokens == 0

    num_words_in_wrapped_lines = 0
    if num_wrapped_lines == 0
      num_words_in_wrapped_lines = num_words
      num_wrapped_lines = 1
    else
      num_words_in_wrapped_lines = num_words - num_words_current_line
    end

    text_block = TextBlock.new(@text_buffer,
                               @current_contained_text_elements,
                               num_words,
                               num_linked_words,
                               num_words_in_wrapped_lines,
                               num_wrapped_lines, @offsetBlocks)

   @current_contained_text_elements = Set.new
   @offset_blocks += 1
   clear_buffers
   text_block.set_tag_level(block_tag_level)
   add_text_block(text_block)
   @block_tag_level -= 1
  end

#public void flushBlock() {
#    int numWords = 0;
#    int numLinkedWords = 0;
#    int numWrappedLines = 0;
#    int currentLineLength = -1; // don't count the first space
#    final int maxLineLength = 80;
#    int numTokens = 0;
#    int numWordsCurrentLine = 0;
#}

  private

  def add_text_block(text_block)
  end

  # append space if last character wasn't already one
  def append_space
    return if @sb_last_was_whitespace
    @sb_last_was_whitespace = true

    @text_buffer << ' '
    @token_buffer << ' '
  end

  def append_text(string)
    @sb_last_was_whitespace = false
    @text_buffer << string
    @token_buffer <<  string
  end

  def clear_buffers
   @token_buffer.clear
   @text_buffer.clear
  end
end
