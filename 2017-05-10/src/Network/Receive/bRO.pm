#############################################################################
#  OpenKore - Network subsystem												#
#  This module contains functions for sending messages to the server.		#
#																			#
#  This software is open source, licensed under the GNU General Public		#
#  License, version 2.														#
#  Basically, this means that you're allowed to modify and distribute		#
#  this software. However, if you distribute modified versions, you MUST	#
#  also distribute the source code.											#
#  See http://www.gnu.org/licenses/gpl.html for the full license.			#
#############################################################################
# bRO (Brazil)
package Network::Receive::bRO;
use strict;
use Log qw(warning);
use base 'Network::Receive::ServerType0';
use Globals qw(%charSvrSet $messageSender);

# Sync_Ex algorithm developed by Fr3DBr
sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);
	
	my %packets = (
		'0097' => ['private_message', 'v Z24 V Z*', [qw(len privMsgUser flag privMsg)]], # -1
	);
	# Sync Ex Reply Array 
	$self->{sync_ex_reply} = {
	'0367', '0202', '0886', '0883', '085B', '085A', '085C', '0949', '085D', '0895', '085E', '0888', '085F', '0889', '0860', '088A', '0861', '088B', '0862', '088C', '0863', '088D', '0864', '088E', '0865', '088F', '0281', '0890', '0867', '0891', '0868', '0892', '0869', '02C4', '086A', '0940', '086B', '0894', '086C', '0896', '086D', '023B', '086E', '0898', '086F', '0899', '0870', '089A', '0871', '089B', '0872', '089C', '0873', '07EC', '0874', '089E', '0875', '089F', '0876', '08A0', '0877', '08A1', '0878', '08A2', '0879', '08A3', '087A', '08A4', '087B', '08A5', '087C', '08A6', '087D', '08A7', '087E', '08A8', '087F', '08A9', '0880', '08AA', '0881', '08AB', '0882', '08AC', '0885', '08AD', '0917', '0941', '0918', '0942', '0919', '0943', '091A', '0944', '091B', '0945', '091C', '0946', '091D', '0436', '091E', '0948', '091F', '0364', '0920', '094A', '0921', '094B', '0922', '094C', '0923', '0363', '0924', '094E', '0925', '094F', '0926', '0950', '0927', '0951', '0928', '0952', '0929', '0953', '092A', '0954', '022D', '0955', '092C', '0956', '092D', '0957', '092E', '0958', '092F', '0959', '0930', '07E4', '0931', '095B', '0932', '095C', '0933', '095D', '0934', '095E', '0935', '095F', '0936', '0960', '0937', '0365', '0802', '0962', '0939', '0963', '093A', '0964', '093B', '0965', '093C', '0966', '093D', '0967', '093E', '0968', '093F', '0969'
	};
	
	foreach my $key (keys %{$self->{sync_ex_reply}}) { $packets{$key} = ['sync_request_ex']; }
	foreach my $switch (keys %packets) { $self->{packet_list}{$switch} = $packets{$switch}; }
	
	my %handlers = qw(
		received_characters 099D
		received_characters_info 082D
		sync_received_characters 09A0
	);

	$self->{packet_lut}{$_} = $handlers{$_} for keys %handlers;
	
	return $self;
}

sub sync_received_characters {
	my ($self, $args) = @_;

	$charSvrSet{sync_Count} = $args->{sync_Count} if (exists $args->{sync_Count});
	
	# When XKore 2 client is already connected and Kore gets disconnected, send sync_received_characters anyway.
	# In most servers, this should happen unless the client is alive
	# This behavior was observed in April 12th 2017, when Odin and Asgard were merged into Valhalla
	for (1..$args->{sync_Count}) {
		$messageSender->sendToServer($messageSender->reconstruct({switch => 'sync_received_characters'}));
	}
}

*parse_quest_update_mission_hunt = *Network::Receive::ServerType0::parse_quest_update_mission_hunt_v2;
*reconstruct_quest_update_mission_hunt = *Network::Receive::ServerType0::reconstruct_quest_update_mission_hunt_v2;

1;