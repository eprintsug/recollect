
#RM we will maintain a metadata profile in it's own hash, 
#from this we will create dataset fields AND display metadata AND *add* search fields

$c->{recollect_metadata_profile} = [
	{ field_definition =>	
                      {
                       name       => 'alt_title',
                       type       => 'longtext',
                       input_rows => 3,
                      },
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_Search => 1,
	},
	{ field_definition =>	
                      {
                       name       => 'collection_method',
                       type       => 'longtext',
                       input_rows => '10',
                      },
 
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_Search => 1,
	},


	{ field_definition =>	
                      {
                       name => 'grant',
                       type => 'text',
                      },
 
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
		    {
		     name       => 'provenance',
		     type       => 'longtext',
		     input_rows => '3',
		    },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
                      {
                       name => 'restrictions',
                       type => 'text',
                      },
 
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
                      {
                       name => 'geographic_cover',
                       type => 'text',
                      },

       	summary_page_metadata => 0,
	summary_page_metadata_hidden => 1,
	advanced_search => 1,
	simple_search => 1,
	},

	{ field_definition =>	
                      {
                       name   => 'bounding_box',
                       type   => 'compound',
                       fields => [
                                  {
                                   sub_name => 'north_edge',
                                   type     => 'float',
                                  },
                                  {
                                   sub_name => 'east_edge',
                                   type     => 'float',
                                  },
                                  {
                                   sub_name => 'south_edge',
                                   type     => 'float',
                                  },
                                  {
                                   sub_name => 'west_edge',
                                   type     => 'float',
                                  },
                                 ],
                      },
	summary_page_metadata => 1, #field appears in default summary page metadata (at this position)
	summary_page_metadata_hidden => 0, #field appears in "Read more" hidden summary page metadata
	advanced_search => 0, #field appears in advanced search form
	simple_search => 1, #field included in simple_search fieldset 
	},

	{ field_definition =>	
		    {
		     name => 'language',
		     type => 'text',

		    },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
		    {
		     name => 'metadata_language',
		     type => 'text',

		    },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
                      {
                       name       => 'legal_ethical',
                       type       => 'longtext',
                       input_rows => '10',
                      },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
                      {
                       name        => 'terms_conditions_agreement',
                       type        => 'boolean',
                       input_style => 'medium',
                      },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 0,
	},


	{ field_definition =>	
                      {
                       name   => 'collection_date',
                       type   => 'compound',
                       fields => [
                                  {
                                   sub_name   => 'date_from',
                                   type       => 'date',
                                   render_res => 'day',
                                  },
                                  {
                                   sub_name => 'date_to',
                                   type     => 'date',
                                  },
                                 ],
                      },
 
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 1,
	},


	{ field_definition =>	
                      {
                       name   => 'temporal_cover',
                       type   => 'compound',
                       fields => [
                                  {
                                   sub_name   => 'date_from',
                                   type       => 'date',
                                   render_res => 'day',
                                  },
                                  {
                                   sub_name => 'date_to',
                                   type     => 'date',
                                  },
                                 ],
                      },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 1,
	},


	{ field_definition =>	
                      {
                       name => 'original_publisher',
                       type => 'text',
                      }, 
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 1,
	simple_search => 1,
	},


	{ field_definition =>	
		    {
		     name         => 'related_resources',
		     type         => 'compound',
		     multiple     => 1,
		     render_value => 'EPrints::Extras::render_url_truncate_end',
		     fields       => [
			 {
			  sub_name   => 'url',
			  type       => 'url',
			  input_cols => 40,
			 },
			 {
			  sub_name     => 'type',
			  type         => 'set',
			  render_quiet => 1,
			  options      => [
			      qw(
				pub
				author
				org
				)
			  ],
			 } ],
		     input_boxes   => 1,
		     input_ordered => 0,
		    },
	
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 1,
	},
########### USE ID_NUMBER INSTEAD ################
#	{ field_definition =>	
#                      {
#                       name => 'doi',
#                       type => 'text',
#                      },
# 
#       	summary_page_metadata => 1,
#	summary_page_metadata_hidden => 0,
#	advanced_search => 1,
#	simple_search => 1,
#	},
#
####################################################

	{ field_definition =>	
                      {
                       name => 'retention_date',
                       type => 'date',
                       render_res => 'day',
                      },
 
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 0,
	},


	{ field_definition =>	
                      {
                       name => 'retention_action',
                       type => 'text',
                      },

       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 0,
	},

	{ field_definition =>	
                     {
                       name => 'retention_comment',
                       type => 'longtext',
                      },
       	summary_page_metadata => 1,
	summary_page_metadata_hidden => 0,
	advanced_search => 0,
	simple_search => 0,
	},
];
