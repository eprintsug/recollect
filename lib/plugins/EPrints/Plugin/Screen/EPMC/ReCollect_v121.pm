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
	my $repo = $self->{repository};

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
	my $namedset;	

	$namedset = EPrints::NamedSet->new( "licenses",
		repository => $repo
	);
 
	$namedset->remove_option( "odc_by", $self->{package_name} );
	$namedset->remove_option( "odc_odbl", $self->{package_name} );
	$namedset->remove_option( "odc_dbcl", $self->{package_name} );

	$self->reload_config if !$skip_reload;
}


1;
