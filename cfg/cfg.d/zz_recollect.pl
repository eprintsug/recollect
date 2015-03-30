##### route and activate ReCollectDocuments plugin

#$c->{plugin_alias_map}->{"InputForm::Component::Documents"} = "InputForm::Component::ReCollectDocuments";
#$c->{plugin_alias_map}->{"InputForm::Component::ReCollectDocuments"} = undef;
#$c->{plugins}->{"InputForm::Component::ReCollectDocuments"}->{params}->{disable} = 0;

##### activate NewDeposit plugin

$c->{plugins}->{"Screen::NewDeposit"}->{params}->{disable} = 0;

#### overide eprint_render

$c->{recollect_eprint_render} = $c->{eprint_render};

$c->{eprint_render} = sub {

    my ($eprint, $repository, $preview) = @_;
    
    if($eprint->value("type") ne "data_collection"){
	#trad. eprint_render for most items
	return $repository->call("recollect_eprint_render", $eprint, $repository, $preview);
    }

####### All this nonsense ######

	my $succeeds_field = $repository->dataset( "eprint" )->field( "succeeds" );
	my $commentary_field = $repository->dataset( "eprint" )->field( "commentary" );

	my $flags = { 
		has_multiple_versions => $eprint->in_thread( $succeeds_field ),
		in_commentary_thread => $eprint->in_thread( $commentary_field ),
		preview => $preview,
	};
	my %fragments = ();

	# Put in a message describing how this document has other versions
	# in the repository if appropriate
	if( $flags->{has_multiple_versions} )
	{
		my $latest = $eprint->last_in_thread( $succeeds_field );
		if( $latest->value( "eprintid" ) == $eprint->value( "eprintid" ) )
		{
			$flags->{latest_version} = 1;
			$fragments{multi_info} = $repository->html_phrase( "page:latest_version" );
		}
		else
		{
			$fragments{multi_info} = $repository->render_message(
				"warning",
				$repository->html_phrase( 
					"page:not_latest_version",
					link => $repository->render_link( $latest->get_url() ) ) );
		}
	}		


	# Now show the version and commentary response threads
	if( $flags->{has_multiple_versions} )
	{
		$fragments{version_tree} = $eprint->render_version_thread( $succeeds_field );
	}
	
	if( $flags->{in_commentary_thread} )
	{
		$fragments{commentary_tree} = $eprint->render_version_thread( $commentary_field );
	}


	foreach my $key ( keys %fragments ) { $fragments{$key} = [ $fragments{$key}, "XHTML" ]; }
	

	my $title = $eprint->render_citation("brief");

	my $links = $repository->xml()->create_document_fragment();
	if( !$preview )
	{
		$links->appendChild( $repository->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
		$links->appendChild( $repository->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );
	}

###### Is there because... #####
	my $page = $eprint->render_citation( "recollect_summary_page", %fragments, flags=>$flags );


###### This bit doesn't really work : gives a Template not loaded error #######
	#to define a specific template to render the abstract with, you can do something like:
	# my $template;
	# if( $eprint->value( "type" ) eq "article" ){
	# 	$template = "article_template";
	# }
	# return ( $page, $title, $links, $template );

###### In theory we could remove most of the above and just ... #######
    	# my ($page, $title, $links) = $repository->call("recollect_eprint_render", $eprint, $repository, $preview);
	#return( $page, $title, $links "recollect_summary_page");

####### But... #######
	return( $page, $title, $links );

};

###################################################################################################
############################### Apply the recollect metadata profile ##############################
###################################################################################################

#To *add* different traditional eprint fields to the summary page metadata (defined in eprints_render.pl) do this:

push (@{$c->{summary_page_metadata}},
    qw/
      creators
    /
);

push (@{$c->{summary_page_metadata_hidden}},
    qw/
      corp_creators
    /
);

#To entirely control the summary_page_metadata from this file redefine the whole thing like this:

#push $c->{summary_page_metadata} = qw/
#	
#	/);

#push $c->{summary_page_metadata_full} = qw/
#	
#	/);


#Apply the recollect metadata profile

for my $recollect_field (@{$c->{recollect_metadata_profile}}){
	
	#Add fields to database
	$c->add_dataset_field(
                      "eprint",
			$recollect_field->{field_definition},
                      reuse => 1
                     );

	#This will automatically *add* *recollect* fields to the summary_page_metadata depending on flag in recollect MD profile object
	#To reorder just reorder the recollect_metadata_profile
	#If you need to mix the order of recollect and trad fields then comment out below and redefine as above
	push @{$c->{summary_page_metadata}}, $recollect_field->{field_definition}->{name} if($recollect_field->{summary_page_metadata});
	push @{$c->{summary_page_metadata_full}}, $recollect_field->{field_definition}->{name} if($recollect_field->{summary_page_metadata_hidden});

	#apply search flag to sub fields of compounds if set
	if($recollect_field->{field_definition}->{type} eq "compound" &&
			($recollect_field->{advanced_search} || $recollect_field->{simple_search})
		){ 
		for my $sub (@{$recollect_field->{field_definition}->{fields}}){
			push @{$c->{search}->{advanced}->{search_fields}}, { meta_fields => [ $recollect_field->{field_definition}->{name}."_".$sub->{sub_name} ] } if($recollect_field->{advanced_search});
			push @{$c->{search}->{simple}->{search_fields}->[0]->{meta_fields}}, $recollect_field->{field_definition}->{name}."_".$sub->{sub_name} if($recollect_field->{simple_search});
		}
	}else{
		#This will automatically *add* *recollect* fields to the advanced search form depending on flag in recollect MD profile object
		push @{$c->{search}->{advanced}->{search_fields}}, { meta_fields => [ $recollect_field->{field_definition}->{name} ] } if($recollect_field->{advanced_search});
		#To reorder just reorder the recollect_metadata_profile
		
		#This will automatically *add* *recollect* fields to the simple search form depending on flag in recollect MD profile object
		#NB assumes simple_Search has one field.... which it generally does
		push @{$c->{search}->{simple}->{search_fields}->[0]->{meta_fields}}, $recollect_field->{field_definition}->{name}  if($recollect_field->{simple_search});
	}	
}

#RM not here... we are not assuming that *everything* will be a data_collection so type only set in NewCollection.pm
#####  add  data_collection as default type
#
#$c->{recollect_set_eprint_defaults} = $c->{set_eprint_defaults};
#$c->{set_eprint_defaults} = sub
#{
#	my( $data, $repository ) = @_;
#	$repository->call("recollect_set_eprint_defaults");
#	if(!EPrints::Utils::is_set( $data->{type} ))
#	{
#		$data->{type} = "data_collection";	
#	}
#};

#### add automatic values for publisher and date

$c->{recollect_set_eprint_automatic_fields} = $c->{set_eprint_automatic_fields};
$c->{set_eprint_automatic_fields} = sub
{
	my( $eprint ) = @_;
	#$repo->call("recollect_set_eprint_automatic_fields", $eprint);
	if(!$eprint->is_set( "publisher" ) ) 
                {
                         $eprint->set_value( "publisher", "UK Data Archive" );
                }
	my $lastmod = $eprint->get_value( "lastmod" );
	if(!$eprint->is_set( "date" ) ) 
                {
                         $eprint->set_value( "date", $lastmod );
                }
};

#####  add embargo date cap at 2 years


$c->{recollect_validate_document} = $c->{validate_document};
$c->{validate_document} = sub {
    my ($document, $repository, $for_archive) = @_;
    my $eprint = $document->get_eprint();

	if($eprint->value("type") ne "data_collection"){
            return $repository->call("recollect_validate_document");
         }

    my @problems = ();

    my $xml = $repository->xml();

    # CHECKS IN HERE

    # "other" documents must have a description set
    if ($document->value("format") eq "other"
        && !EPrints::Utils::is_set($document->value("formatdesc")))
    {
        my $fieldname =
          $xml->create_element("span", class => "ep_problem_field:documents");
        push @problems,
          $repository->html_phrase(
                                   "validate:need_description",
                                   type => $document->render_citation("brief"),
                                   fieldname => $fieldname
                                  );
    } ## end if ($document->value("format"...))

    # security can't be "public" if date embargo set
    if ($document->value("security") eq "public"
        && EPrints::Utils::is_set($document->value("date_embargo")))
    {
        my $fieldname =
          $xml->create_element("span", class => "ep_problem_field:documents");
        push @problems,
          $repository->html_phrase("validate:embargo_check_security",
                                   fieldname => $fieldname);
    } ## end if ($document->value("security"...))

    #
##### embargo expiry date currently capped at 2 years
##### to change update my $embargo_cap
    #
    if (EPrints::Utils::is_set($document->value("date_embargo")))
    {
        my $value = $document->value("date_embargo");
        my ($thisyear, $thismonth, $thisday) = EPrints::Time::get_date_array();
        my ($year, $month, $day) = split('-', $value);
        if (   $year < $thisyear
            || ($year == $thisyear && $month < $thismonth)
            || ($year == $thisyear && $month == $thismonth && $day <= $thisday))
        {
            my $fieldname = $xml->create_element("span",
                                         class => "ep_problem_field:documents");
            push @problems,
              $repository->html_phrase("validate:embargo_invalid_date",
                                       fieldname => $fieldname);
        } ## end if ($year < $thisyear ...)

        my $embargo_cap = $thisyear + 1;
        if (   $year > $embargo_cap
            || ($year == $embargo_cap && $month > $thismonth)
            || (   $year == $embargo_cap
                && $month == $thismonth
                && $day >= $thisday))
        {
            my $fieldname = $xml->create_element("span",
                                         class => "ep_problem_field:documents");
            push @problems,
              $repository->html_phrase("validate:embargo_too_far_in_future",
                                       fieldname => $fieldname);

        } ## end if ($year > $embargo_cap...)

    } ## end if (EPrints::Utils::is_set...)
    return (@problems);
};

=head1 NAME

EPrints::Plugin::Screen::EPrint

=cut


package EPrints::Plugin::Screen::EPrint::Edit;

use EPrints::Plugin::Screen;

#@ISA = ( 'EPrints::Plugin::Screen' );

#use strict;

sub workflow_id
{
	my ($plugin) = @_;
	my $repo = $plugin->get_repository;
	my $eprint = $plugin->{processor}->{eprint};
	$repo->log("In recollect cfg.d:workflow_id => ".$eprint->value("type"));
	
	if($eprint->value("type") eq "data_collection"){
		return "recollect";
	}
	if($eprint->value("type") eq "collection"){
		return "collection";
	}
	return "default";
}

#remove the default item colection...
$c->{plugins}->{"Screen::NewEPrint"}->{appears}->{item_tools} = undef;
