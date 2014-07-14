=head1 NAME

EPrints::Plugin::InputForm::Component::ReCollectDocuments

=cut

package EPrints::Plugin::InputForm::Component::ReCollectDocuments;

use EPrints::Plugin::InputForm::Component;
@ISA = ( "EPrints::Plugin::InputForm::Component::Documents" );

use strict;


sub _render_doc_div 
{
	my( $self, $doc, $hide ) = @_;

	my $session = $self->{session};

	my $docid = $doc->get_id;
	my $doc_prefix = $self->{prefix}."_doc".$docid;

	my $imagesurl = $session->current_url( path => "static" );

	my $files = $doc->get_value( "files" );
	do {
		my %idx = map { $_ => $_->value( "filename" ) } @$files;
		@$files = sort { $idx{$a} cmp $idx{$b} } @$files;
	};

	my $doc_div = $self->{session}->make_element( "div", class=>"ep_upload_doc", id=>$doc_prefix."_block" );

	# provide <a> link to this document
	$doc_div->appendChild( $session->make_element( "a", name=>$doc_prefix ) );

	# note which documents should be updated
	$doc_div->appendChild( $session->render_hidden_field( $self->{prefix}."_update_doc", $docid ) );

	# note the document placement
	$doc_div->appendChild( $session->render_hidden_field( $self->{prefix}."_doc_placement", $doc->value( "placement" ) ) );

	my $doc_title_bar = $session->make_element( "div", class=>"ep_upload_doc_title_bar rd_upload_doc_title_bar" );
	$doc_div->appendChild( $doc_title_bar );

	my $doc_expansion_bar = $session->make_element( "div", class=>"ep_upload_doc_expansion_bar ep_only_js" );
	$doc_div->appendChild( $doc_expansion_bar );

	my $content = $session->make_element( "div", id=>$doc_prefix."_opts", class=>"ep_upload_doc_content ".($hide?"ep_no_js":"") );
	$doc_div->appendChild( $content );


	my $table = $session->make_element( "table", width=>"100%", border=>0 );
	my $tr = $session->make_element( "tr" );
	$doc_title_bar->appendChild( $table );
	$table->appendChild( $tr );
	my $td_left = $session->make_element( "td", align=>"left", valign=>"middle", width=>"60%" );
	$tr->appendChild( $td_left );

	$td_left->appendChild( $self->_render_doc_icon_info( $doc, $files ) );

	my $td_right = $session->make_element( "td", align=>"right", valign=>"middle", class => "ep_upload_doc_actions" );
	$tr->appendChild( $td_right );

	$td_right->appendChild( $self->_render_doc_actions( $doc ) );

        my @fields = $self->doc_fields( $doc );
        return $doc_div if !scalar @fields;

	my $opts_toggle = $session->make_element( "a", onclick => "EPJS_blur(event); EPJS_toggleSlideScroll('${doc_prefix}_opts',".($hide?"false":"true").",'${doc_prefix}_block');EPJS_toggle('${doc_prefix}_opts_hide',".($hide?"false":"true").",'block');EPJS_toggle('${doc_prefix}_opts_show',".($hide?"true":"false").",'block');return false" );
	$doc_expansion_bar->appendChild( $opts_toggle );

	my $s_options = $session->make_element( "div", id=>$doc_prefix."_opts_show", class=>"ep_update_doc_options ".($hide?"":"ep_hide") );
	$s_options->appendChild( $self->html_phrase( "show_options" ) );
	$s_options->appendChild( $session->make_text( " " ) );
	$s_options->appendChild( 
			$session->make_element( "img",
				src=>"$imagesurl/style/images/plus.png",
				) );
	$opts_toggle->appendChild( $s_options );

	my $h_options = $session->make_element( "div", id=>$doc_prefix."_opts_hide", class=>"ep_update_doc_options ".($hide?"ep_hide":"") );
	$h_options->appendChild( $self->html_phrase( "hide_options" ) );
	$h_options->appendChild( $session->make_text( " " ) );
	$h_options->appendChild( 
			$session->make_element( "img",
				src=>"$imagesurl/style/images/minus.png",
				) );
	$opts_toggle->appendChild( $h_options );


	my $content_inner = $self->{session}->make_element( "div", id=>$doc_prefix."_opts_inner" );
	$content->appendChild( $content_inner );

	$content_inner->appendChild( $self->_render_doc_metadata( $doc )->{content} );
	return $doc_div;
}

sub _render_doc_icon_info
{
	my( $self, $doc, $files ) = @_;

	my $session = $self->{session};

	my $table = $session->make_element( "table", border=>0 );
	my $tr = $session->make_element( "tr" );
	my $td_left = $session->make_element( "td", align=>"center" );
	my $td_right = $session->make_element( "td", align=>"left", class=>"ep_upload_doc_title" );
	$table->appendChild( $tr );
	$tr->appendChild( $td_left );
	$tr->appendChild( $td_right );

	$td_left->appendChild( $doc->render_icon_link( new_window=>1, preview=>1, public=>0 ) );
##### call the recollect_default document citation xml here
	$td_right->appendChild( $doc->render_citation( "recollect_default" ) );
	my $size = 0;
	foreach my $file (@$files)
	{
		$size += $file->value( "filesize" );
	}
	if( $size > 0 )
	{
		$td_right->appendChild( $session->make_element( 'br' ) );
		$td_right->appendChild( $session->make_text( EPrints::Utils::human_filesize($size) ));
	}

	return $table;
}

