require 'boilerpipe/version'

require 'boilerpipe/util/unicode_tokenizer'

require 'boilerpipe/document/text_document'
require 'boilerpipe/document/text_block'

require 'boilerpipe/extractors/article_extractor'
require 'boilerpipe/extractors/canola_extractor'
require 'boilerpipe/extractors/default_extractor'
require 'boilerpipe/extractors/keep_everything_extractor'
require 'boilerpipe/extractors/keep_everything_with_k_min_words_extractor'
require 'boilerpipe/extractors/largest_content_extractor'
require 'boilerpipe/extractors/num_words_rules_extractor'

require 'boilerpipe/filters/block_proximity_fusion'
require 'boilerpipe/filters/boilerplate_block_filter'
require 'boilerpipe/filters/canola_classifier'
require 'boilerpipe/filters/density_rules_classifier'
require 'boilerpipe/filters/document_title_match_classifier'
require 'boilerpipe/filters/expand_title_to_content_filter'
require 'boilerpipe/filters/heuristic_filter_base'
require 'boilerpipe/filters/ignore_blocks_after_content_filter'
require 'boilerpipe/filters/keep_largest_block_filter'
require 'boilerpipe/filters/large_block_same_tag_level_to_content_filter'
require 'boilerpipe/filters/list_at_end_filter'
require 'boilerpipe/filters/mark_everything_content_filter'
require 'boilerpipe/filters/min_words_filter'
require 'boilerpipe/filters/num_words_rules_classifier'
require 'boilerpipe/filters/simple_block_fusion_processor'
require 'boilerpipe/filters/terminating_blocks_finder'
require 'boilerpipe/filters/trailing_headline_to_boilerplate_filter'

require 'boilerpipe/labels/default'
require 'boilerpipe/labels/label_action'

require 'boilerpipe/sax/html_content_handler'
require 'boilerpipe/sax/boilerpipe_html_parser'
require 'boilerpipe/sax/tag_action_map'
require 'boilerpipe/sax/tag_actions/chained'
require 'boilerpipe/sax/tag_actions/ignorable_element'
require 'boilerpipe/sax/tag_actions/anchor_text'
require 'boilerpipe/sax/tag_actions/body'
require 'boilerpipe/sax/tag_actions/inline_whitespace'
require 'boilerpipe/sax/tag_actions/inline_no_whitespace'
require 'boilerpipe/sax/tag_actions/block_level'
require 'boilerpipe/sax/tag_actions/font'
require 'boilerpipe/sax/tag_actions/inline_tag_label'
require 'boilerpipe/sax/tag_actions/block_tag_label'
