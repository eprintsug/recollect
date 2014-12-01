package EPrints::Plugin::Screen::EPMC::ReCollect_v121;

@ISA = qw( EPrints::Plugin::Screen::EPMC );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{actions} = [qw( enable disable )];
	$self->{disable} = 0; # always enabled, even in lib/plugins

	$self->{package_name} = "recollect";

	return $self;
}

sub action_enable
{
	my( $self, $skip_reload ) = @_;

	$self->SUPER::action_enable( 1 );

	#check if recollect workflow already exists - if it does, we're upgrading...
	$self->workflow_update();
	
my $data_collection_workflow = '<?xml version="1.0"?>
<workflow xmlns="http://eprints.org/ep3/workflow" xmlns:epc="http://eprints.org/ep3/control">
	  <stage name="recollect_files">
	    <component type="Upload" show_help="always"/>
	    <component type="Documents">
	      <field ref="security"/>
	      <field ref="content" set_name="recollect_content"/>
	      <field ref="formatdesc"/>
	      <field ref="date_embargo"/>
	      <field ref="license" required="yes"/>
	      <!--  <field ref="relation" /> -->
	      <!--  <field ref="language" /> -->
	    </component>
	  </stage>
	<stage name="data_collection">
		<component><field ref="title" required="yes" input_lookup_url="{$config{rel_cgipath}}/users/lookup/title_duplicates" input_lookup_params="id={eprintid}&amp;dataset=eprint&amp;field=title" /></component>
		<component><field ref="abstract" required="yes"/></component>
		<component><field ref="keywords" required="yes"/></component>
		<component><field ref="divisions" required="yes"/></component>

		<component collapse="yes"><field ref="alt_title"/></component>
		<component><field ref="creators" required="yes" input_lookup_url="{$config{rel_cgipath}}/users/lookup/name" /></component>
		<component collapse="yes"><field ref="corp_creators"/></component>
		<epc:if test="$STAFF_ONLY = \'TRUE\'">
			<component show_help="always"><field ref="doi"/></component>
		</epc:if>
		<component><field ref="data_type" required="yes" input_lookup_url="{$config{perl_url}}/users/lookup/simple_file" input_lookup_params="file=data_type" /></component>

		<component><field ref="contributors" collapse="yes" /></component>
		<component type="Field::Multi">
		    <title>Research Funders</title>
		    <field ref="funders" input_lookup_url="{$config{perl_url}}/users/lookup/simple_file" input_lookup_params="file=funders" />
		    <field ref="projects"/>
		    <field ref="grant" collapse="yes" />
		</component>
		<component type="Field::Multi">
		    <title>Time period</title>
		    <help>Help text here</help>
		    <field ref="collection_date" required="yes" />
		    <field ref="temporal_cover" />
		</component>
		<component collapse="yes"><field ref="geographic_cover"/></component>
		<component type="Field::Multi" show_help="always" collapse="yes">
		    <title>Geographic location</title>
		    <help>Enter if applicable the Longitude and Latitude values of a theoretical geographic bounding rectangle that would cover the region in which your data were collected. You can use</help>
		    <field ref="bounding_box" />
		</component>
		<component collapse="yes"><field ref="collection_method"/></component>
		<component collapse="yes"><field ref="legal_ethical"/></component>
		<component collapse="yes"><field ref="provenance"/></component>
		<component type="Field::Multi">
		    <title>Language</title>
			<field ref="language" required="yes"/>
			<field ref="metadata_language" required="yes"/>
		</component>
		<component collapse="yes"><field ref="note"/></component>
		<component collaspe="yes"><field ref="related_resources"/></component>
		<epc:if test="$STAFF_ONLY = \'TRUE\'">
			<component type="Field::Multi">
			    <title> Original Publication Details</title>
			    <field ref="publisher"/>
			    <field ref="ispublished"/>
			    <field ref="official_url"/>
			    <field ref="date" />
			    <field ref="date_type"/>
			</component>
		</epc:if>
		<component><field ref="copyright_holders" required="yes" /></component>


		<component><field ref="contact_email" required="yes"/></component>
		<component collapse="yes"><field ref="suggestions"/></component>
	<epc:if test="$STAFF_ONLY = \'TRUE\'">
    <component type="Field::Multi">
      <title>Retention Information</title>
      <field ref="retention_date"/>
      <field ref="retention_action"/>
      <field ref="retention_comment"/> 
    </component>
</epc:if>
	</stage>
</workflow>';


	my $repo = $self->{repository};
	my $xml = $repo->xml;

	my $filename = $repo->config( "config_path" )."/workflows/eprint/default.xml";

	EPrints::XML::add_to_xml( $filename, $data_collection_workflow, $self->{package_name} );

	my $dom = $xml->parse_file( $filename );

	my @flow = $dom->getElementsByTagName("flow");
	my $flow_elements = $xml->create_document_fragment();

	foreach my $element ($flow[0]->childNodes()){
		$element->unbindNode();
		$flow_elements->appendChild($element);
	}

	my $choose_statement = $xml->create_element("epc:choose", required_by=>"recollect", id=>"recollect_choose");
	$flow[0]->appendChild($choose_statement);

	my $when_statement = $xml->create_element("epc:when", test=>"type = 'data_collection'");
	$choose_statement->appendChild($when_statement);
	$when_statement->appendChild($xml->create_element("stage", ref=>"recollect_files"));
	$when_statement->appendChild($xml->create_element("stage", ref=>"data_collection"));
	$when_statement->appendChild($xml->create_element("stage", ref=>"subjects"));

	my $otherwise_statement = $xml->create_element("epc:otherwise");
	$choose_statement->appendChild($otherwise_statement);
	$otherwise_statement->appendChild($flow_elements);

	open( FILE, ">", $filename );

	print FILE $xml->to_string($dom, indent=>1);

	close( FILE );

	my $namedset;

	$namedset = EPrints::NamedSet->new( "licenses",
		repository => $repo
	);
 
	$namedset->add_option( "odc_by", $self->{package_name} );
	$namedset->add_option( "odc_odbl", $self->{package_name} );
	$namedset->add_option( "odc_dbcl", $self->{package_name} );

	$self->reload_config if !$skip_reload;
}

sub action_disable
{
	my( $self, $skip_reload ) = @_;

	$self->SUPER::action_disable( 1 );

	my $repo = $self->{repository};
	my $xml = $repo->xml;
	my $filename = $repo->config( "config_path" )."/workflows/eprint/default.xml";

	my $dom = $xml->parse_file( $filename );

	my $choose;
	my @choices = $dom->getElementsByTagName("choose");
	foreach my $element (@choices)
	{
		if($element->hasAttribute("required_by") && $element->getAttribute("required_by") eq $self->{package_name})
		{
			$choose = $element;
			last;
		}
	}

	if(defined $choose) {
		my $choose_parent = $choose->parentNode; #probably the flow element but err on the side of caution
		my @otherwise = $choose->getElementsByTagName("otherwise");
		foreach my $element ($otherwise[0]->childNodes()){
			$element->unbindNode();
			$choose_parent->appendChild($element);
		}

		open( FILE, ">", $filename );

		print FILE $xml->to_string($dom, indent=>1);

		close( FILE );
	}

	EPrints::XML::remove_package_from_xml( $filename, $self->{package_name} );


	$dom = $xml->parse_file( $filename );

	open( FILE, ">", $filename );

	print FILE $xml->to_string($dom, indent=>1);

	close( FILE );

	my $namedset;	

	$namedset = EPrints::NamedSet->new( "licenses",
		repository => $repo
	);
 
	$namedset->remove_option( "odc_by", $self->{package_name} );
	$namedset->remove_option( "odc_odbl", $self->{package_name} );
	$namedset->remove_option( "odc_dbcl", $self->{package_name} );

	$self->reload_config if !$skip_reload;
}

sub workflow_update
{

	my ($self) = @_;

	my $repo = $self->{repository};
	my $xml = $repo->xml;
	my $filename = $repo->config( "config_path" )."/workflows/eprint/default.xml";

	my $dom = $xml->parse_file( $filename );

	my $choose;
	my @choices = $dom->getElementsByTagName("choose");

	foreach my $element (@choices)
	{
		if($element->hasAttribute("required_by") && $element->getAttribute("required_by") eq $self->{package_name})
		{
			$choose = $element;
			last;
		}
	}

	# if required_by eq recollect exists flush the elements before adding the v121 workflow
	if(defined $choose) {
		my $choose_parent = $choose->parentNode; #probably the flow element but err on the side of caution
		my @otherwise = $choose->getElementsByTagName("otherwise");
		foreach my $element ($otherwise[0]->childNodes()){
			$element->unbindNode();
			$choose_parent->appendChild($element);
		}

		open( FILE, ">", $filename );

		print FILE $xml->to_string($dom, indent=>1);

		close( FILE );


	EPrints::XML::remove_package_from_xml( $filename, $self->{package_name} );


	$dom = $xml->parse_file( $filename );

	open( FILE, ">", $filename );

	print FILE $xml->to_string($dom, indent=>1);

	close( FILE );


	}

}	

1;
