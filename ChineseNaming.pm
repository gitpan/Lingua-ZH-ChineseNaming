package Lingua::ZH::ChineseNaming;

use 5.006;
use strict;

use Carp;
our $VERSION = '0.02';
require Exporter;
our @ISA = qw/Exporter/;
my $CHARS;
my %STROKEDB;

sub is_Big5_CHAR {
    local $_=shift;
    1 if /^[\xA4-\xC5][\x40-\x7E]/o || /^[\xA4-\xC5][\xA1-\xFE]/o ||
        /^\xA3[\x40-\x7E]/o || /^[\xA4-\xC5][\x40-\x7E]/o ||
            /^[\xA4-\xC5][\xA1-\xFE]/o;
}


sub loadchar{
    my $i = 1;
    foreach my $s (split /\n/, $CHARS){
	foreach ( grep {$_} split /\s/, $s ){
	    $STROKEDB{$_} = $i;
	}
	$i++;
    }
}

sub strokes{
    [ map { $STROKEDB{$1} } $_[0]=~/(..)/og ];
}

sub analyze{
    my (%arg) = @_;
    my (%ch);
    my ($fn, $gn) = ($arg{FAMILY_NAME}, $arg{GIVEN_NAME});
    my ($stfn, $stgn) = (strokes($fn), strokes($gn));
    no strict;
    my (%handle) = (
	22 => sub {
	    %ch = (
		   heavenly => $stfn->[0] + 1,
		   personal => $stfn->[0] + $stgn->[0],
		   earthly => $stgn->[0] + 1,
		   external => 2,
		   general => $stfn->[0] + $stgn->[0] + 2
		   );
	},
	24 => sub {
	    %ch = (
		   heavenly => $stfn->[0] + 1,
		   personal => $stfn->[0] + $stgn->[0],
		   earthly => $stgn->[0] + $stgn->[1],
		   external => 1 + $stgn->[1],
		   general => $stfn->[0] + $stgn->[0] + $stgn->[1] +1
		   );

	},
	42 =>  sub {
	    %ch = (
		   heavenly => $stfn->[0] + $stfn->[1],
		   personal => $stfn->[1] + $stgn,
		   earthly => $stgn + 1,
		   external => 2,
		   general => $stfn->[0] + $stfn->[1] + $stgn->[0] + 1
		   );

	},
	44 =>  sub {
	    %ch = (
		   heavenly => $stfn->[0] + $stfn->[1],
		   personal => $stfn->[1] + $stgn->[0],
		   earthly => $stgn->[0] + $stgn->[1],
		   external => $stgn->[1] + 1,
		   general => $stfn->[0] + $stfn->[1] + $stgn->[0] + $stgn->[1],
		   );
	    
	},
    );
    (%arg, $handle{length($fn).length($gn)}->($fn, $gn));
}

sub hexagram{
    my (%arg) = @_;
    my (@ba_gua) = qw/qian dui li zhen xun kan gen kun/;
    my (@yinyang)=qw/--------- -x------- ----x---- -x--x----
	-------x- -x-----x- ----x--x- -x--x--x-/;
    my $stgn = strokes($arg{GIVEN_NAME});
    my ($upper, $lower) = ( $arg{general} % 8,  ($stgn->[0] + $stgn->[1]) % 8 );
    (%arg, ( hexagram => $ba_gua[ $upper ]." over ".$ba_gua[ $lower ],
	     diagram =>
	     join qq/\n/, map{ s/x/ /o;$_ }
	     map { $yinyang[$_] =~ /(...)(...)(...)/o; $1,$2,$3 } $upper, $lower));
}

sub new{
    my($pkg) = shift;
    my(%arg) = @_;
    my %r;
    $r{FAMILY_NAME} = $arg{FAMILY_NAME} or croak "Family name?";
    $r{GIVEN_NAME}  = $arg{GIVEN_NAME}  or croak "Given name?";
    loadchar();
    %r = analyze(%r);
    %r = hexagram(%r);
    bless \%r, $pkg;
}



1;

$CHARS=<<EOF;
�@ �A
�P �Q �N �C �G �R �K �D �I �M �F �L �S �E �B �O �H �J
�e �y �| �} �q �b �s �g �r �] �j �Y �c �i �m �n �U �a �k �T �h �z �p �{ �x �\ �w �^ �V �f �` �_ �X �o �d �t �u �~ �[ �Z �v �W �l
�� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� ��
�� �� �J �I �D �� �a �r �U �� �� �B �n �� �^ �� �� �� �k �h �[ �C �� �s �� �� �j �� �� �� �_ �� �� �} �� �� �� �� �� �� �� �x �c �b �A �e �~ �\ �� �q �� �v �� �E �u �� �� �� �F �g �G �� �f �� �W �� �� �� �� �� �� �� �� �� �` �l �� �� �Q �m �{ �p �H �X �� �Z �y �� �� �M �� �� �� �N �� �O �] �� �� �@ �t �i �R �� �� �d �w �T �o �� �� �S �� �Y �V �K �z �� �P �| �� �� �� �� �� �L ��
�� �b �E �� �O �Q �` �Y �� �� �� �� �� �� �� �u �� �C �V �� �� �� �x �� �� �� �� �z �� �� �U �� �� �� �� �� �� �\ �K �� �� �Z �� �� �f �� �R �� �@ �� �� �� �� �� �r �g �� �� �e �� �p �� �^ �� �� �j �� �� �M �a �l �I �� �F �� �� �h �� �� �� �� �� �B �� �n �� �� �} �� �� �� �� �� �v �� �� �P �t �� �� �� �� �] �X �� �� �{ �� �D �� �� �W �c �� �� �� �� �� �_ �N �� �� �T �y �� �� �� �[ �� �� �S �� �� �� �� �� �q �d �� �� �L �G �J �� �~ �� �m �� �o �� �� �� �k �� �A �i �� �� �� �w �H �| �� �� �� �� �s
�� �r �� �b �@ �_ �N �� �a �H �� �� �� �E �� �� �� �b �� �� �N �� �� �� �� �f �y �e �t �z �d �� �� �K �� �X �� �� �G �h �� �� �� �R �� �^ �] �� �R �V �Y �� �� �m �� �q �O �� �E �K �� �� �� �� �� �C �� �j �T �� �r �w �q �L �F �L �S �� �� �� �� �� �� �m �c �� �p �C �i �� �� �e �� �� �� �� �� �u �� �� �D �W �� �[ �� �� �� �~ �� �s �� �j �U �� �� �c �� �v �W �� �� �\ �} �� �S �J �� �i �B �� �x �� �� �D �� �` �� �� �� �P �n �X �u �� �� �� �� �T �� �� �� �A �� �{ �o �� �h �� �� �o �� �F �Z �� �� �� �J �� �[ �� �M �� �� �� �{ �� �P �� �� �f �_ �� �� �O �l �� �� �� �w �} �� �t �� �I �M �� �� �| �� �a �~ �� �� �I �� �Q �� �� �A �� �� �� �� �@ �� �� �n �� �� �U �y �Z �� �z �� �� �� �� �s �V �� �� �� �g �\ �� �� �� �G �` �d �� �� �] �� �k �� �� �� �� �B �p �� �� �� �l �Q �� �x �v �Y �� �k �� �� �� �� �� �� �� �g �� �^ �| �H 
�� �} �z �� �� �P �f �� �i �I �� �� �� �b �Y �� �� �� �G �L �� �� �� �m �[ �� �b �_ �� �P �� �� �� �� �� �� �� �� �� �q �� �� �J �� �� �� �A �u �� �� �� �e �� �� �� �� �M �� �� �� �� �s �� �{ �� �B �h �] �T �\ �� �Y �� �� �� �� �n �� �F �� �� �� �� �� �� �� �S �� �� �� �� �� �� �p �K �� �g �� �� �� �� �� �� �� �� �� �T �m �� �� �� �~ �� �` �U �� �� �L �� �H �x �� �D �� �H �� �t �l �� �� �� �c �� �� �� �� �� �� �@ �� �O �Q �� �� �� �� �� �K �� �� �� �� �G �� �� �� �� �� �U �� �z �r �\ �~ �w �� �h �� �D �� �X �� �� �o �� �� �c �� �q �� �J �� �V �� �� �} �� �� �g �� �� �a �� �C �V �� �d �� �� �� �� �R �� �D �� �� �� �A �O �� �� �� �� �C �� �� �� �C �� �` �� �� �v �� �E �� �� �k �� �k �x �� �� �� �� �� �N �� �� �l �� �� �� �[ �] �� �� �W �� �� �� �� �� �Q �� �� �� �� �� �� �� �� �� �_ �� �Z �d �S �@ �r �� �� �� �� �� �p �{ �� �� �� �� �I �� �f �� �� �� �� �n �� �^ �� �j �� �X �� �B �� �E �i �B �� �� �j �y �@ �� �� �� �� �� �� �� �� �W �� �N �� �� �� �F �� �� �� �v �� �� �a �w �� �� �� �� �� �t �s �y �� �� �� �� �� �^ �� �u �� �� �� �� �� �� �� �� �� �� �� �e �� �� �� �� �o �| �� �� �R �| �� �� �� �� �A �� �M �� �� �� �Z ��
�z �� �_ �X �� �� �b �C �O �T �� �� �w �� �� �� �m �� �~ �� �u �� �N �� �� �q �j �s �� �` �N �� �� �V �D �| �H �h �S �� �g �� �H �� �K �� �� �j �� �w �� �P �� �� �m �^ �� �l �� �X �Q �� �� �� �v �i �r �� �\ �W �C �� �G �� �t �d �E �� �� �� �n �� �} �n �� �� �� �� �n �[ �� �� �� �i �Z �� �w �� �b �x �� �L �D �{ �p �A �� �� �i �� �y �P �F �a �c �� �� �M �� �� �� �� �l �� �� �� �I �� �� �F �o �� �f �q �W �k �_ �� �� �� �I �\ �� �� �� �e �� �v �_ �r �a �� �� �� �Y �� �S �� �� �� �� �X �� �] �� �� �P �U �k �[ �� �R �] �� �s �� �r �� �� �� �O �� �B �� �{ �Q �� �� �� �� �J �� �� �v �E �� �� �| �A �� �� �z �l �� �` �E �u �� �j �K �� �f �� �] �R �� �� �� �F �� �p �Y �y �� �� �� �� �� �� �� �� �@ �V �| �p �� �� �� �y �� �� �� �� �� �� �U �� �� �� �� �g �� �� �b �� �Q �Z �R �� �Y �q �T �� �� �� �� �� �� �u �� �� �L �� �� �c �� �� �{ �� �x �z �d �� �� �� �\ �O �e �� �f �a �Z �} �� �B �� �J �t �� �� �t �� �� �� �� �� �J �� �} �� �� �� �� �� �^ �I �� �K �� �` �o �� �S �� �� �� �� �c �^ �� �� �� �� �� �h �� �x �� �� �g �� �V �� �� �� �� �� �� �� �� �� �� �� �d �T �� �� �U �� �h �� �� �� �[ �� �o �� �G �~ �� �� �� �� �� �� �@ �k �� �W �� �� �� �� �~ �N �M �� �� �e �G �� �� �m �M �s �H �L ��
�P �� �� �l �� �� �{ �C �� �� �I �� �� �E �b �� �F �� �W �� �� �� �^ �� �� �� �] �P �� �� �Z �F �� �� �� �� �u �� �n �� �v �� �� �M �� �s �O �f �� �� �� �M �q �m �� �� �R �m �� �X �| �� �b �[ �� �� �� �� �� �� �� �t �� �� �� �X �V �| �� �d �g �S �� �� �� �A �� �� �B �� �� �� �� �y �r �q �� �� �� �i �G �r �� �S �x �� �� �� �p �� �� �� �w �N �� �g �{ �� �z �p �� �� �� �m �� �B �U �E �D �V �� �H �� �� �j �O �� �^ �� �c �\ �M �� �� �w �{ �Z �� �� �� �� �� �� �� �� �� �X �� �� �� �� �� �� �� �Y �� �� �] �� �� �� �� �� �� �� �� �� �@ �� �h �R �� �\ �x �n �� �� �~ �c �� �� �� �� �q �d �� �� �n �� �� �T �� �� �� �� �� �� �j �� �� �� �Q �� �� �h �� �� �� �� �N �� �Y �� �t �� �� �� �� �� �� �_ �^ �� �� �A �H �f �� �� �] �� �� �� �� �� �_ �� �� �z �� �� �� �K �� �� �O �� �| �� �E �y �� �i �� �� �Z �A �� �h �~ �u �� �L �� �l �� �R �U �� �� �t �� �� �Y �� �� �� �C �� �� �� �U �s �G �� �� �� �� �� �K �V �d �� �G �� �� �� �� �k �� �g �_ �� �~ �� �� �� �� �� �� �w �K �Q �� �z �c �o �� �� �� �s �H �` �D �� �� �N �` �� �� �� �k �k �� �� �T �I �� �b �` �@ �� �� �f �� �� �L �� �� �� �� �e �y �� �� �S �x �� �J �a �J �� �� �� �} �� �e �� �i �� �� �j �� �� �� �} �� �� �Q �� �[ �v �T �L �� �� �o �� �� �� �J �} �u �D �� �� �� �� �� �a �� �� �� �\ �� �e �v �[ �� �W �� �� �� �� �� �� �� �� �r �� �� �� �P �� �� �p �� �� �� �W �� �� �� �� �� �� �a �� �B �� �� �� �o �C �F �l �@ �I 
�� �� �^ �G �� �K �� �� �� �u �� �� �� �� �� �� �R �B �l �X �� �� �A �� �� �� �L �� �� �� �� �N �� �� �� �h �O �� �� �� �A �c �� �� �� �| �� �� �� �� �� �[ �� �� �A �� �� �� �� �H �� �t �� �i �� �� �F �{ �r �� �e �} �� �\ �� �a �m �� �� �� �� �� �� �� �D �| �� �� �k �� �� �E �� �i �_ �b �� �� �~ �� �� �O �� �� �� �Q �� �� �X �� �� �� �� �� �� �d �� �� �� �q �S �� �� �� �W �� �� �� �� �� �O �� �y �� �� �� �� �� �y �� �� �d �H �� �� �� �� �� �� �� �] �� �V �� �� �� �r �U �� �M �� �� �� �� �� �� �� �] �o �@ �p �� �� �| �{ �K �Y �G �L �c �� �� �� �� �� �� �b �� �� �� �� �l �� �@ �q �� �h �g �f �G �� �� �j �� �� �� �� �R �z �v �` �� �x �� �~ �� �� �� �� �� �s �g �� �� �U �� �u �\ �� �� �B �m �v �� �Y �� �D �} �� �R �� �N �� �� �� �� �� �� �� �V �J �I �� �� �� �� �� �� �p �Q �� �� �� �m �� �S �� �� �� �k �� �� �� �� �� �� �C �� �[ �� �� �� �{ �� �� �Z �� �� �d �n �� �� �� �� �� �� �� �� �� �M �w �J �� �� �� �s �� �� �c �\ �� �� �Q �w �j �Z �r �� �H �� �� �I �v �� �X �� �` �n �V �� �� �� �� �� �a �M �C �� �� �� �� �� �f �~ �� �� �� �z �U �� �� �� �� �_ �w �f �� �� �� �� �� �� �� �� �� �g �� �� �� �� �� �� �� �� �E �� �� �� �� �t �� �� �C �� �J �Z �[ �T �s �S �n �� �� �� �� �F �� �u �� �j �N �F �� �i �� �` �k �� �� �P �� �� �� �� �x �K �� �t �P �� �� �� �� �_ �� �D �] �� �� �I �e �@ �b �� �Y �o �� �� �o �� �� �� �� �� �� �� �� �� �� �� �T �� �� �} �� �L �� �� �x �� �� �� �� �h �B �� �� �y �� �T �� �� �� �p �^ �E �� �� �q �e �� �^ �� �z �l �a �W �W �� �� �� �P 
�� �f �F �b �k �� �� �y �� �o �] �� �{ �H �� �{ �� �r �� �T �� �� �� �u �� �\ �� �� �� �_ �� �� �� �Z �� �i �� �� �N �� �� �E �� �� �K �� �� �� �G �T �� �~ �� �� �� �� �� �Q �� �� �� �� �m �X �P �� �� �b �� �� �� �� �� �� �A �x �m �� �� �� �@ �i �� �Y �� �| �� �u �� �] �� �A �� �� �� �� �� �� �c �� �� �N �l �� �� �K �� �R �z �[ �� �� �E �r �� �� �� �G �_ �� �� �n �� �� �� �� �� �� �� �@ �� �W �S �c �� �� �� �� �M �E �� �Y �� �� �� �p �w �H �� �� �U �� �� �� �� �� �n �� �� �F �� �� �z �P �� �� �X �� �� �U �� �� �� �� �� �h �C �� �{ �� �� �t �` �� �� �� �� �b �c �� �� �w �I �� �� �v �� �� �~ �� �� �� �� �Y �O �� �� �� �� �� �� �g �� �t �d �� �� �J �� �s �� �� �� �� �p �� �^ �� �� �z �� �� �H �� �� �� �o �` �� �k �� �x �� �k �� �� �� �� �� �t �� �� �� �� �� �� �v �S �� �M �� �� �s �� �m �� �W �� �� �j �� �Q �� �F �� �y �d �� �� �� �� �L �j �^ �h �� �� �e �� �� �B �x �� �� �� �� �� �� �V �a �� �O �� �� �B �g �~ �y �D �� �V �I �o �� �� �� �[ �| �J �[ �} �� �� �h �� �� �d �� �l �� �q �_ �� �J �C �� �� �� �� �Q �g �� �� �e �� �� �q �� �V �N �� �S �e �� �� �� �� �� �u �I �� �� �� �^ �Z �i �� �� �� �� �P �� �� �L �� �� �� �` �R �O �� �� �� �� �| �@ �� �� �� �� �p �� �K �� �D �� �� �f �� �T �q �] �� �j �� �� �� �� �� �� �� �� �� �� �} �D �C �a �� �� �} �A �f �� �n �L �� �� �v �� �� �s �� �\ �� �r �� �� �� �W �� �� �� �� �� �� �� �M �� �w �\ �� �X �� �U �� �� �� �� �� �R �l �G �Z �� �B �� �a �� �� �� 
�� �� �E �L �A �� �@ �� �{ �� �� �X �� �� �C �� �� �� �� �S �� �� �E �} �w �r �N �� �� �X �� �� �^ �� �� �� �� �Z �� �� �� �O �� �s �\ �� �� �� �S �� �� �� �� �P �x �� �� �F �� �i �@ �� �� �� �� �p �Y �� �� �� �J �U �� �C �D �� �� �� �� �� �n �g �� �K �� �� �~ �S �� �a �� �h �� �I �� �s �� �� �� �� �R �d �� �F �� �c �H �c �] �� �� �� �K �� �� �A �� �` �n �k �� �� �� �� �T �� �g �� �� �� �G �� �� �� �� �� �O �� �� �� �v �r �l �r �� �� �| �A �� �� �q �q �_ �� �� �� �D �m �O �F �] �� �| �� �Z �e �� �T �p �� �i �� �� �� �� �@ �� �� �I �� �z �k �V �� �� �h �{ �W �� �� �� �� �w �I �� �� �� �� �� �� �c �� �o �� �� �T �� �� �� �N �t �� �L �� �� �� �` �� �b �� �� �� �� �Y �� �o �� �x �� �` �� �� �� �� �� �k �d �� �L �� �b �} �� �Q �� �u �P �� �� �� �� �� �� �N �\ �� �� �� �{ �V �� �� �R �� �j �� �s �� �� �� �� �u �[ �J �� �H �� �� �� �� �B �� �� �y �� �� �z �� �� �p �� �U �� �� �W �v �z �� �� �� �� �H �� �� �� �� �� �h �� �y �� �_ �� �a �� �e �D �� �� �t �\ �� �Z �� �� �B �b �~ �� �j �o �x �� �� �J �W �� �t �� �� �� �� �� �y �� �� �^ �� �| �� �� �� �� �� �E �K �� �[ �� �l �� �� �e �M �� �v �_ �� �] �� �� �� �M �� �~ �� �f �j �g �� �R �� �n �� �� �� �Q �Y �� �m �P �� �� �� �� �� �V �� �� �� �� �� �m �� �� �l �� �G �U �X �a �� �i �� �� �� �q �� �� �� �f �G �� �� �d �� �M �f �Q �C �B �� �� �� �} �� �^ �� �� �� �[ �� �� �� �w �u �� �� 
�� �� �� �� �J �� �� �L �h �� �Z �� �\ �P �� �� �F �� �� �� �l �� �U �� �� �� �� �y �W �� �� �� �� �c �� �� �� �� �K �u �] �� �w �� �� �z �n �� �� �� �� �� �C �� �� �G �� �e �` �� �� �D �� �� �� �[ �� �� �� �� �� �~ �l �j �� �� �� �� �� �� �� �s �q �R �� �� �� �� �} �� �� �� �� �� �� �� �� �� �g �T �p �� �� �z �� �t �� �� �� �� �� �� �� �� �S �� �k �� �� �~ �� �� �^ �� �� �` �v �� �t �� �� �P �� �J �E �S �� �� �� �� �g �� �� �� �f �� �� �} �� �y �� �� �� �Z �� �� �� �G �o �@ �� �� �_ �� �d �� �� �� �� �� �N �p �� �� �� �� �� �� �� �� �� �O �[ �� �� �� �� �� �� �� �� �� �� �� �T �� �_ �� �� �k �� �� �� �� �f �� �� �� �� �� �W �Y �� �� �� �n �� �� �� �� �� �� �� �� �� �s �Q �I �� �� �� �� �� �w �@ �� �� �� �� �e �� �� �� �� �� �| �� �D �\ �A �h �B �� �� �� �u �b �� �� �x �� �X �H �� �� �� �K �� �q �� �� �� �{ �� �O �� �c �� �i �� �� �� �� �^ �� �� �� �o �� �U �� �� �� �� �| �� �b �M �� �� �� �Q �� �Y �x �M �� �� �� �� �� �� �� �� �� �A �� �� �� �� �F �v �� �� �� �� �] �� �V �� �N �H �i �� �� �� �� �� �m �� �a �� �� �� �� �� �� �� �� �� �R �� �{ �� �a �� �� �� �� �E �� �d �� �V �R �� �� �I �X �B �m �� �� �� �� �L �C �j �� �� �� �� �� �� �� �� �r �r 
�Q �� �{ �W �v �� �� �� �� �@ �d �� �� �� �� �m �� �b �� �� �v �� �� �� �� �� �{ �� �� �D �G �� �U �� �_ �� �X �Q �~ �� �n �� �� �� �� �M �� �� �N �x �� �� �F �� �p �B �g �� �H �G �� �� �A �t �u �� �i �Y �� �� �o �� �n �d �� �` �M �� �� �s �� �� �z �c �H �� �� �u �� �� �� �z �n �U �� �� �i �R �} �c �Q �� �g �] �� �� �� �� �� �� �_ �R �� �[ �� �{ �� �� �� �g �S �L �� �� �� �� �A �[ �� �� �O �y �� �� �F �� �� �P �� �� �l �l �� �@ �X �� �� �\ �� �� �� �K �� �� �o �� �L �C �O �� �f �� �e �� �� �| �k �� �h �� �� �a �� �� �� �E �F �X �� �V �P �u �\ �� �h �I �� �~ �� �P �o �K �� �� �T �� �� �t �� �q �] �p �� �M �^ �f �Z �� �Z �r �� �T �I �� �� �� �� �W �� �� �} �� �v �� �� �� �� �� �x �_ �� �� �� �� �~ �� �� �� �� �S �y �� �Z �e �� �x �� �� �E �Y �� �s �t �� �� �� �� �G �j �� �� �� �k �k �@ �B �� �m �O �a �� �� �J �� �} �� �K �� �b �N �^ �S �� �r �] �� �� �� �W �J �� �p �w �� �� �a �� �� �� �� �i �� �D �� �V �r �e �[ �� �E �^ �| �� �� �� �� �Y �l �� �U �� �q �� �� �� �� �� �\ �� �B �� �L �d �� �� �y �w �� �c �� �� �D �j �H �` �T �� �� �� �w �� �I �m �� �� �J �f �� �C �q �� �� �� �� �� �� �� �j �� �� �� �V �s �N �� �� �` �� �� �� �� �b �� �| �� �C �� �h �� �A �z �� 
�~ �� �� �R �� �k �x �O �� �� �h �� �� �� �L �} �T �� �� �e �\ �� �r �@ �� �� �G �X �� �� �A �� �� �� �� �q �� �H �S �� �G �� �� �� �� �A �� �W �� �� �� �� �D �� �d �� �� �� �� �P �K �E �� �K �� �u �� �X �� �[ �� �� �� �� �� �� �o �a �� �N �N �� �� �� �z �� �� �� �� �� �p �� �� �� �� �� �� �� �f �U �O �� �� �� �� �M �^ �� �� �� �� �Y �� �@ �S �� �b �m �� �i �� �� �� �V �� �� �� �i �C �� �J �F �� �j �T �� �� �� �� �� �p �� �Z �` �� �� �� �� �y �� �� �� �P �� �� �� �� �L �f �� �Q �J �� �v �� �_ �� �� �� �F �� �[ �� �{ �o �� �� �� �� �� �_ �c �� �c �s �� �� �� �t �C �� �� �� �� �� �� �� �� �I �� �� �` �� �\ �� �� �� �� �� �� �� �h �� �I �V �� �� �� �� �j �� �E �B �� �� �� �� �H �� �� �] �� �� �| �� �Y �s �b �� �� �� �l �� �q �� �W �^ �� �l �] �� �Z �e �R �� �� �� �� �g �� �r �� �� �� �� �� �� �M �B �� �� �� �� �m �t �� �� �� �� �D �� �� �� �U �� �Q �n �n �� �� �� �g �w �k �� �a �� �d 
�� �� �Z �� �� �� �� �� �q �� �� �_ �� �� �~ �� �� �` �� �� �� �� �� �� �d �� �� �� �� �C �� �S �� �� �i �� �� �w �F �� �� �O �� �M �t �� �� �w �� �� �B �] �J �� �� �� �� �c �� �� �� �� �� �E �� �� �� �F �� �� �� �{ �I �� �� �� �� �� �� �� �� �� �� �� �g �T �� �� �� �M �W �� �� �� �R �[ �� �� �� �� �h �� �� �� �� �� �� �A �l �Q �� �{ �� �� �� �v �� �� �� �o �� �� �� �N �� �� �� �� �K �� �� �v �� �� �� �^ �u �L �� �p �� �� �G �z �� �b �� �� �H �� �� �� �� �A �� �y �� �N �� �} �f �� �� �� �� �H �y �� �� �} �~ �� �� �\ �n �� �� �� �m �� �� �� �� �� �� �X �� �B �� �� �� �� �K �� �� �E �� �� �z �k �| �� �� �s �G �P �U �� �� �� �� �� �� �� �� �� �� �� �D �� �� �J �� �� �� �� �� �� �� �� �I �� �x �� �� �a �� �� �� �� �� �� �� �� �� �@ �� �� �j �� �� �C �� �e �� �� �� �x �D �� �� �� �Y �� �L �� �� �� �� �� �V �� �u �| �� �r �@ 
�� �k �@ �� �� �� ¼ �S �B ¸ �c �� �S �� �^ �� �h �U �} ² �� �X �� �� �� �� �� �w �� �s �� �� �P �X �� �D �p �\ �� �� ° �T �] �� ¾ �o ¿ �e �P �N �b ¢ ¬ �� « �Z �L �a �Y ¤ �� �� �� �F · �H �v �| �� ¦ �� § �y �� �Z �� © �� º �u �V �J �� �� �^ ³ �W �[ ± �� �g �_ �l �] �� �t �� �� �� ½ �A ® �� �f �z �� �� �i �j ¹ �� �d » �� �E �U �� �� �T �q �R �� �R �Q �� �� �Y ­ ¶ �n �W µ �� �\ £ ¡ �� �{ �� �� �O ª �� ¨ �� �� �~ �� �x �� �M ¥ �Q �[ �G �� �� �� �� �� �I ´ �r ¯ �` �C �K �� �m �O �V �� 
�� �� �k ð �a �� �� �Q �� �� ô �� �� �� ø �� �C �� ï �M á ö �� �p �� �l �� �� �P ò �y å �� �� �� �f �~ ç �� �J ì �� �L �| �N ã �b �S �� þ �� �� �i õ è �� �� ê �� �� �� �{ ü �w �� �H �u �E �� �e �F ù �� �T �� �� �� �� �h �� �O �� �` �� �o �� ý �m �B �@ �� �� �j �� �q �� ÷ �_ ú �D �� î �� �� ñ �� �g û �V �r �� ä �x �s �� �v �� �I â �� �� �} í �z ó æ �� �t ë �� �d �R �� �� ÿ é �c �n �� �A �� �� �� �G �� �K �� �� 
İ ħ �^ į �~ �� �Y �s �_ �v �� ľ ĸ �| ĥ ġ Į �y ķ �� �h �� ļ �[ �� �Z �� ĺ �{ �\ �j �a �� �� ĩ �U �� �e �� Ĵ Ĭ �� �p �w �X �t Ĳ Ŀ �� �� ĳ �c �� �� �b �l �� ı �W �k �� �� �g �� ī �o Ī �� Ĥ �x �m Ħ Ĺ ĵ Ĩ �q �` �] �u Ķ �z Ļ �r �i �f ģ Ģ �� �n �� ĭ �� Ľ �d �} 
�F �� �� �` �� �Z �c �E �� �W �� �� �] �_ �\ �� �� �� �a �� �O �C �I �� �X �� �� �� �[ �Y �G �� �� �f �� �d �� �� �� �� �� �b �� �� �P �e �� �K �� �Q �� �L �� �� �A �B �j �i �M �@ �g �� �� �� �D �S �� �R �N �� �� �� �^ �H �� �U �� �� �T �� �J �V �h 
š Ŧ �v �z �t Ž �k Ÿ ų Ŭ ů Ţ �� �� �p ŷ Ů �y �s �� Ŷ �q �{ Ź Ű Ų ţ �| Ŵ �� �m ū �� �l �~ �u ſ �} ź ű �w �n Ũ ŵ ũ ŭ �� ŧ �� �r ż ž Ť �� Ū �o ť Ż �x 
�� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� 
�� �� �� �� �� �� �� �� �� �� �� �� �� �� 
EOF

__END__

=head1 NAME

Lingua::ZH::ChineseNaming - Analyzing Chinese Names

=head1 SYNOPSIS

  use Lingua::ZH::ChineseNaming;
  my $n = new Lingua::ZH::ChineseNaming( # Chen Yuan-yuan
                                      FAMILY_NAME => '��',
                                      GIVEN_NAME => '���'
				      );

  print Dumper $n;


=head1 DESCRIPTION

 Naming is an art and choosing an auspicious one is a
 long-standing tradition in Chinese communities. Many
 people hold firmly that to have a good name is to have
 an auspicious life.

 Analyzing and choosing a good name always uses several
 patterns, e.g. stroke-counting, Chinese-horoscope, 
 hexagrams, but there is never a scientific foundation
 for these patterns.

 Lingua::ZH::ChineseNaming avoids to be a fortune-teller,
 but only extracts the computable part of this tradition
 and tries not to be confined to any specific school of
 interpreters.

=head1 METHODS


=over 1

=item *
 new Lingua::ZH::ChineseNaming(FAMILY_NAME => HERE, GIVEN_NAME => HERE) starts analysis

    my $n = new Lingua::ZH::ChineseNaming( # Chen Yuan-yuan
                                      FAMILY_NAME => '��',
                                      GIVEN_NAME => '���'
					    );

    then, it gives statistics like this.

      FAMILY_NAME => '��',    # Chen
      GIVEN_NAME  => '���',  # Yuan-yuan
      heavenly    => 12,
      personal    => 24
      earthly     => 26,
      external    => 14,
      general     => 38,
      hexagram    => 'gen over li',
      chart       => '---
                      - -
                      - -
                      ---
                      - -
                      ---'

=back


=head1 ILLUSTRATIONS

=over 8

=item * FAMILY NAME

Chinese family names are mostly a single character.

=item * GIVEN NAME

comes in one or two characters.

=item * HEAVENLY CHARACTER

implies the influence of ancestry on a person.

=item * PERSONAL CHARACTER

implies one's disposition or inner attributes.

=item * EARTHLY CHARACTER

implies the relation between the environment and
person

=item * EXTERNAL CHARACTER

is combined with one's heavenly character and earthly
character, representing the external factors of one 
person.

=item * GENERAL CHARACTER

is addition of one's heavenly, personal, and earthly
characters.

=item * HEXAGRAM

is formally introduced to history in I-CHING thousand 
years ago, and is given for your own interpretation.

=back

=head1 CAVEAT

=over 2

=item * It is only for casual amusement. No practical use

=item * Characters are all encoded in Big5 for now.

=back

=head1 REFERENCE

Almost every kind of book on Chinese naming is 
written in Chinese. I list two books in English
for you reference.

=over 2

=item * Choosing Auspicious Chinese Name by Evelyn Lip

=item * I CHING, The Oracle by Kerson Huang

=back

=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.


=cut
