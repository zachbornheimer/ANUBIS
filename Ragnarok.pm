#!/usr/bin/perl

###################################################
# Ragnarok.pm #####################################
# Intialized by Z. Bornheimer #####################
# Released as Open Source (attribution required). #
###################################################

=pod

=head1 NAME
 
 Ragnarok.pm - The Ragnarok Encryption Module

=head1 DESCRIPTION
 
 The Ragnarok Prevention Module is a part of the ANUBIS Package.
 It contains the encrption algorithm for ANUBIS API.
 
=head1 ARGUMENTS
 
 The Ragnarok Prevention Module accepts the following arguments:
 
=over 4

=item version

=item returnusername

=item username=<string>

=item password=<string>
 
=item aboutkey=<string>
 
=item aboutcode=<string> 

Note: AboutKey or Key must be defined
 
=item generate=<string>

Note: key and code must be defined unless you are generating
the key or code.  If generating the key, aboutkey must be set.
If generating the code aboutkey or key must be set.  If generating
the IRCode, it is only valid for today and tomorrow.
 
=over 4

 The possible values for the generate argument are:
 * key
 * code 
 * proof
 * installcode
 * removalcode
 
=back
 
=item ircode=<string>

=item key=<string>

=item code=<string>

=item proof=<string>

=item validator

=back

=head1 ERROR CODES

The Ragnarok Prevention Module contains the following error codes:

=over 4

=item -4

This error, also known as E_KEY_NOT_DEFINED, comes about if $Key
or $AboutKey are not set during the _generatecode algorithm.

=item -3

This error, also known as E_NOTHING_TO_GENERATE, comes about
when an invalid option is passed to generate and it does not
generate anything.

=item -2

This error, also known as E_INVALID_IRCODE, comes about
in the properties algorithm if the supplied IRCode is
invalid.

=item -1

This error, also known as E_INVALID_PROPERTY, comes about
if the first argument to property is not a non-negative
integer.

=back

=head1 SYNOPSIS

 
 use Ragnarok;
 
 my $r = new Ragnarok();

 # Always define the key before defining the code.
 # You can't type in the code on the keypad if you can't
 # get through the door :) Also, Ragnarok returns an error if you try.
 
 $r->properties(ABOUTKEY, $aboutKey);
 $r->properties(KEY, $r->generate(ABOUTKEY));
 $r->properties(ABOUTCODE, $aboutCode);
 $r->properties(CODE, $r->generate(ABOUTCODE));


 my $proof = $r->generate(PROOF);
 $r->properties(PROOF, $proof);
 
 if ($r->properties(IRCODE, $installcode) == E_INVALID_IRCODE) {
    die "Sorry, invalid install code.";
 } else {
    # VALID INSTALL CODE
 }
 
 if ($r->properties(IRCODE, $removalcode) == E_INVALID_IRCODE) {
    die "Sorry, invalid removal code.";
 } else {
    # VALID REMOVAL CODE
 }
 

=head1 FUNCTION DOCUMENTATION
 
=cut

package Ragnarok;

use strict;
use Crypt::Rijndael;
use Digest::SHA qw(sha384_hex);
use Math::Round;
use Getopt::Long;
use Carp;
require constant;
require Cwd;
require Switch;

#use diagnostics-verbose;

### Subroutine Prototypes
sub new;
sub properties;
sub generate;
sub _areValidCLIOptions;
sub _basicAuthentication;
sub _encrypt;
sub _fix;
sub _generatecode;
sub _generatekey;
sub _generateircode;
sub _generateproof;
sub _generateproof_api;
sub _generateupass;
sub _isValidInstallRemovalCode;
sub _makeKey;
sub _makeReadable;
sub _ragnarokObliterationProtocol;
sub _ragnarokPrevention;
sub _removeTrailingLineBreak;
### END Subroutine Prototypes

my ($Key, $Code, $Proof, $AboutKey, $AboutCode, $installcode, $removalcode, $validator, $IRCode, $generatekey, $generatecode, $generateproof, $generateupass, $username, $password, $returnusername,);
use constant {
              E_KEY_NOT_DEFINED     => -4,
              E_NOTHING_TO_GENERATE => -3,
              E_INVALID_IRCODE      => -2,
              E_INVALID_PROPERTY    => -1,
              KEY                   => 0,
              USERNAME              => 0,
              GENERATE_KEY          => 0,
              CODE                  => 1,
              PASSWORD              => 1,
              GENERATE_CODE         => 1,
              PROOF                 => 2,
              GENERATE_PROOF        => 2,
              IRCODE                => 3,
              GENERATE_INSTALL_CODE => 3,
              INSTALLCODE          => 3,
              ABOUTKEY              => 4,
              GENERATE_REMOVAL_CODE => 4,
              REMOVALCODE          => 4,
              ABOUTCODE             => 5,
              GENERATEUNAME         => 5,
              GENERATEUPASS         => 6,
              ITERATION_NUMBER      => 13,
              AVERAGE_KEY_SIZE      => 400,
              VERSION               => '0.7.1',
             };    ## end constant declarations

### Module Info
require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter AutoLoader);

@EXPORT = qw ( new properties E_KEY_NOT_DEFINED E_NOTHING_TO_GENERATE
     E_INVALID_IRCODE E_INVALID_PROPERTY KEY CODE PROOF IRCODE 
     ABOUTKEY ABOUTCODE USERNAME PASSWORD GENERATE_KEY
     GENERATE_CODE GENERATE_PROOF GENERATE_INSTALL_CODE REMOVALCODE
     GENERATE_REMOVAL_CODE GENERATEUPASS GENERATEUNAME INSTALLCODE
    );
$VERSION = VERSION;
### END Module Info

GetOptions(
    'aboutkey=s'     => \$AboutKey,
    'aboutcode=s'    => \$AboutCode,
    'key=s'          => \$Key,
    'code=s'         => \$Code,
    'proof=s'        => \$Proof,
    'validator'      => \$validator,
    'ircode=s'       => \$IRCode,
    'username=s'     => \$username,
    'password=s'     => \$password,
    'returnusername' => \$returnusername,
    'version'        => sub {
        print 'Ragnarok Encryption Module Version ' . $VERSION . "\n";
    },
    'generate=s' => sub {
        my ($option, $value) = @_;
        my %generateHash = (
                            'key'         => \$generatekey,
                            'code'        => \$generatecode,
                            'proof'       => \$generateproof,
                            'installcode' => \$installcode,
                            'removalcode' => \$removalcode,
                            'upass'       => \$generateupass,
                           );

        if ($generateHash{$value}) {
            ${$generateHash{$value}} = 1;
        }
    },    ## end generate=s
);        ## end GetOptions

my $madeKey;
MAIN: {
    exit unless (_areValidCLIOptions());
    if ($Key) {
        _makeKey(\$Key);
        $madeKey = 1;
    }

    print _generatekey($AboutKey) if ($generatekey && $AboutKey);
    print _generatecode($AboutCode) if ($generatecode && $Key && $AboutCode);
    print _generateproof() if ($generateproof && $Key && $Code);
    print _generateircode() if ($installcode || $removalcode);
    print _isValidInstallRemovalCode($IRCode) if ($validator && $IRCode);
    print _generateupass($username, $password) if ($generateupass && $username && $password);

} ## end MAIN:

### OO Class Implementation ###

=pod

=head2 new

 new is the constructor for the object oriented implementation
 of Ragnarok. It takes no arguments.

=cut

sub new {
    my $self = {};
    $self->{KEY}       = $Key;
    $self->{CODE}      = $Code;
    $self->{PROOF}     = $Proof;
    $self->{IRCODE}    = $IRCode;
    $self->{ABOUTKEY}  = $AboutKey;
    $self->{ABOUTCODE} = $AboutCode;

    bless($self);
    return $self;
} ## end sub new

=pod

=head2 properties

 properties is an api function that allows the setting of
 different properties and the recalling of those properties.
 To set a property, give properties two arguments, the enum
 value and the value to set.  To recall a value, give the
 subroutine one argument, the enum value.  The valid
 property types (a.k.a. enum values) are the following:

=over 4

 * KEY
 * CODE
 * PROOF
 * IRCODE
 * ABOUTKEY
 * ABOUTCODE
 
=back

=cut

sub properties {
    my $self = shift;
    my $type = shift;    # first argument
    return E_INVALID_PROPERTY if ($type > 5);

    use Switch;

    # if two arguments are given, it sets the first to the second
    # then returns.  If only one is given, it just returns.

    switch ($type) {
        case 0 {
            if (@_) {
                $self->{KEY} = shift;
                $Key = $self->{KEY};
            }
            return $Key;
        } ## end case 0
        case 1 {
            if (@_) {
                $self->{CODE} = shift;
                $Code = $self->{CODE};
            }
            return $self->{CODE};
        } ## end case 1
        case 2 {
            if (@_) {
                $self->{PROOF} = shift;
                $Proof = $self->{PROOF};
            }
            return $self->{PROOF};
        } ## end case 2
        case 3 {
            if (@_) {
                ${$self->{IRCODE}} = shift;
                $IRCode = $self->{IRCODE};
            }
            if (_isValidInstallRemovalCode($self->{IRCODE})) {
                return $self->{IRCODE};
            } else {
                return E_INVALID_IRCODE;
            }
        } ## end case 3
        case 4 {
            if (@_) {
                $self->{ABOUTKEY} = shift;
                $AboutKey = $self->{ABOUTKEY};
            }
            return $self->{ABOUTKEY};
        } ## end case 4
        case 5 {
            if (@_) {
                $self->{ABOUTCODE} = shift;
                $AboutCode = $self->{ABOUTCODE};
            }
            return $self->{ABOUTCODE};
        } ## end case 5
        else {
            return E_INVALID_PROPERTY;
        }
    } ## end switch
} ## end sub properties

=pod

=head2 generate

 generate is an api function that accepts one argument,
 a number representing what to generate.  Options are
 from following list of enumerated options (Note: some
 options have synonyms):

=over 4

 * GENERATE_KEY or KEY
 * GENERATE_CODE or CODE
 * GENERATE_PROOF or PROOF
 * GENERATE_INSTALL_CODE or INSTALLCODE
 * GENERATE_REMOVAL_CODE or REMOVALCODE
 * GENERATEUPASS
 * GENERATEUNAME
 
=back

=cut

sub generate {
    my $self = shift;
    my $gen  = shift;

    use Switch;

    switch ($gen) {
        case GENERATE_KEY {
            return _generatekey($self->{ABOUTKEY});
        }
        case GENERATE_CODE {
            return _generatecode($self->{ABOUTCODE});
        }
        case GENERATE_PROOF {
            return _generateproof_api($self->{KEY}, $self->{CODE});
        }
        case GENERATE_INSTALL_CODE {
            $installcode = 1;
            my $retval = _generateircode();
            $installcode = undef;
            return $retval;
        } ## end GENERATE_INSTALL_CODE
        case GENERATE_REMOVAL_CODE {
            $removalcode = 1;
            my $retval = _generateircode();
            $removalcode = undef;
            return $retval;
        } ## end GENERATE_REMOVAL_CODE
        case GENERATEUPASS {
            return _generateupass($self->{USERNAME}, $self->{PASSWORD});
        }
        case GENERATEUNAME {
            $returnusername = 1;
            my $retval = _generateupass($self->{USERNAME}, $self->{PASSWORD});
            $returnusername = undef;
            return $retval;
        } ## end GENERATEUNAME
        else {
            return E_NOTHING_TO_GENERATE;
        }
    } ## end switch
} ## end sub generate

### END OO CLASS IMPLEMENTATION

### INTERNAL SUBROUTINES ###

#############################################################
#### Subroutine: _areValidCLIOptions ###########################
#############################################################
# This subroutine checks to see if the options given to #####
# the commandline are in the proper pairs.  If the pairs ####
# are not defined, the subroutine returns 0 and the program #
# exits without warning. ####################################
#############################################################

sub _areValidCLIOptions {

    my %correctCommandCombinations = (
                                      'generatekey_aboutkey'       => defined($generatekey   && $AboutKey),
                                      'generatecode_aboutcode_key' => defined($generatecode  && $AboutCode && $Key),
                                      'generateproof_key_code'     => defined($generateproof && $Key && $Code),
                                      'generateuname'              => defined($generateupass && $username && $password),
                                      'validator_ircode'           => defined($validator     && $IRCode),
                                      'nothing_defined'            => !defined($generatekey  && $generatecode && $generateproof && $AboutKey && $AboutCode && $validator && $IRCode),
                                     );

    foreach my $key (%correctCommandCombinations) {
        return 1 if ($correctCommandCombinations{$key});
    }

    return 0;

} ## end sub _areValidCLIOptions

#####################################################################
#### Subroutine: _basicAuthentication ###############################
#####################################################################
# Takes no argument.  The prompter checks to see if the #############
# key, code, and/or proof were set via argument and, if not, ########
# asks for that information.  It will make sure that the accessor ###
# has a properly matching key, code, and proof strings.  If they ####
# match, the _basicAuthentication function exits otherwise it sends #
# itself into an infinite loop with the word "OBLITERATING..." ######
# appending itself to the output of the program. ####################
#####################################################################

sub _basicAuthentication {
    my ($badAttempts, $continue, $obliterate);
    $badAttempts = ITERATION_NUMBER;
    until ($continue) {
        unless ($Key) {
            print 'Please enter the Ragnarok Prevention Module Unlock Key: ';
            chomp($Key = <STDIN>);
        }

        unless ($obliterate) {
            unless ($Code) {
                print 'Please enter the Ragnarok Prevention Code: ';
                $Code = <STDIN>;
                _removeTrailingLineBreak(\$Code);
            }

            unless ($Proof) {
                print 'Please enter the Ragnarok Prevention Module ', 'Proof of Authentication Now: ';
                my $Proof = <STDIN>;
                _removeTrailingLineBreak(\$Proof);
            }

            my $data = $Code;
            _makeKey(\$Key) unless $madeKey;

            _encrypt(\$data);

            if ($Proof eq $data) {
                print 'Ragnarok Prevention Module Authentication Successful.';
                my $exitloop = 'yes';

            } else {
                $badAttempts++;
                print
                  'Ragnarok Prevention Module Authentication FAILURE.  ',
                  'The Ragnarok Obliteration Protocol will be activated.';
            } ## end else [ if ($Proof eq $data) ]

            if ($badAttempts > ITERATION_NUMBER) {
                my $exitloop = 'yes';
                _ragnarokObliterationProtocol();
            }
        } else {
            print 'Initiating the RAGNAROK OBLITERATION PROTOCOL...';
            _ragnarokObliterationProtocol();
            return 0;
        } ## end else
    } ## end until ($continue)
    return 1;
} ## end sub _basicAuthentication

#########################################################
#### Subroutine: _encrypt ###############################
#########################################################
# Takes one argument, a reference to the string to ######
# encrypt. This runs the _ragnarokPrevention subroutine #
# and,therefore, the encryption algorithm. ##############
#########################################################

sub _encrypt {
    my $string = shift;
    for (0 .. (ITERATION_NUMBER- 1)) {
        _ragnarokPrevention($string);
    }
} ## end sub _encrypt

#######################################################
#### Subroutine: _fix #################################
#######################################################
# Takes one argument, a reference to the string whose #
# length needs to be a multiple of 16 bytes.  This ####
# subroutine works by appending the null byte to the ##
# original string after calculating how many it needs #
# to append via basic arithmatic. #####################
#######################################################

sub _fix {
    my $data   = shift;
    my $length = length(${$data});
    while ($length >= 16) {
        $length -= 16;
    }
    ${$data} .= ("\0" x (16 - $length)) unless $length == 0;
} ## end sub _fix

##########################################################
#### Subroutine: generatecode ############################
##########################################################
# generatecode takes one argument, the $AboutCode ########
# string. It is also necessary for the key or the ########
# aboutkey to be defined (it will autogenerate the #######
# key if the about key is defined). If $Key is not #######
# defined, it is unable to generate the code. ############
##########################################################

sub _generatecode {
    my $aboutcode = shift;
    _generatekey($AboutKey) if ($Key != "");
    if ($Key) {
        my $code = _generatekey($aboutcode . $Key);
        _encrypt(\$code);
        _shortenKey(\$code, AVERAGE_KEY_SIZE);
        _makeReadable(\$code);
        return $code;
    } else {
        return E_KEY_NOT_DEFINED;
    }
} ## end sub _generatecode

###########################################################
####Subroutine: generatekey ###############################
###########################################################
# _generatekey takes one argument, the $AboutKey string. ##
# It encrypts the $AboutKey string and uses that as both ##
# the encrypting key and data.  It encrypts the key with ##
# the key as its own salt. ################################
###########################################################

sub _generatekey {
    my $aboutkey = shift;
    _makeKey(\$aboutkey);
    $Key = $aboutkey;
    _encrypt(\$aboutkey);
    _shortenKey(\$aboutkey, AVERAGE_KEY_SIZE);
    _makeReadable(\$aboutkey);
    return $aboutkey;
} ## end sub _generatekey

#################################################################
#### Subroutine:  _generateircode ###############################
#################################################################
# _generateircode requires that the $Key and $Code be set #######
# otherwise it will fail.  It generates the install/removal #####
# code necessary to install or remove a server from the ANUBIS ##
# server list.  Each code fails after the date differs too much #
# from the date that is encrypted within the string. ############
#################################################################

sub _generateircode {
    _basicAuthentication();
    exit unless defined($Key && $Code);
    my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    my $year   = 1900 + $yearOffset;
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my $time   = $months[$month] . '/' . ($dayOfMonth + 1) . '/' . $year;
    my $type;
    if ($installcode) {
        $type = 'install';
    } elsif ($removalcode) {
        $type = 'removal';
    } else {
        $type = 'sabotage';
    }
    my $id = $Key . $Code . $time . $type;
    _encrypt(\$id);
    return $id;
} ## end sub _generateircode

###############################################
#### Subroutine: _generateproof ###############
###############################################
# Generates the proof via encrypting the code #
# with the key as the salt. ###################
###############################################

sub _generateproof {
    return _generateproof_api($Key, $Code);
}

############################################################
#### Subroutine: _generateproof_api ########################
############################################################
# Generates the proof via encrypting the second argument ###
# with the first argument as the salt.  _generateproof_api #
# allows both the salt and data to be given as arguments ###
# to the subroutine. #######################################
############################################################

sub _generateproof_api {
    my ($key, $code) = @_;

    my $original_key  = $key;
    my $original_code = $code;
    foreach ($key, $code) {
        _fix(\$_);
        $Key = $_;
        _makeKey(\$Key);
        for (0 .. ITERATION_NUMBER) {
            _makeKey(\$_);
            $key = reverse($_);
            $key = $original_code . $key . $original_key;
            _encrypt(\$_);
            $key = reverse($_);
            $Key = $_;
            _makeKey(\$Key);
        } ## end for (0 .. ITERATION_NUMBER)
        $Key = $_;
        _makeKey(\$Key);
        _encrypt(\$_);
    } ## end foreach ($key, $code)
    $Key = $key;
    _makeKey(\$Key);
    $Code = $code;
    _fix(\$Code);
    $Proof = $Code;
    _encrypt(\$Proof);
    return $key if ($returnusername);
    return $Proof;
} ## end sub _generateproof_api

############################################################################
#### Subroutine: _generateupass ############################################
############################################################################
# This subroutine generates the proof code for when given ##################
# a username and password.  This is for the webapi.  This ##################
# replace the current idea of encrypting a password and ####################
# having a username stored.  This idea, has the username stored ############
# only in a temporary cookie, when a successful login has been #############
# processed.  In a database, the only thing that needs to be stored ########
# is the proof (a user id and username are recommended as to prevent #######
# a user from knowing that, upon registering, a username and password ######
# combination is unavailible because it exists).  This way, a username #####
# acts as a password as well, and the salt to the password is not stored. ##
# The other benefit is that it also increases security by not exposing a ###
# username incase of database dumping, just a usesless proofcode is shown. #
############################################################################
# In version 0.6.1 we have made the $username variable use the original ####
# password as well as the original username to salt the encryption.  This ##
# means that it is impossible to recover a user account if  the password ###
# is forgotton.  This decision comes after we realized that it is better ###
# to lose access to your account than for an unauthorized user to be able ##
# to buy his or herself a new Rolex Watch on your debit card. ##############
############################################################################

sub _generateupass {
    my ($username, $password) = @_;
    return _generateproof_api($username, $password);
}

########################################################
#### Subroutine: _isValidInstallRemovalCode ############
########################################################
# This subroutine checks to see if the ir code #########
# is valid not only in general, but also for this ######
# moment in time.  It generates all the possiblities ###
# and compares them to the string given.  The argument #
# to the function is the ircode. #######################
########################################################

sub _isValidInstallRemovalCode {
    my $ircode = shift;
    _basicAuthentication();
    my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime(time);
    my $year     = 1900 + $yearOffset;
    my @months   = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my $time     = $months[$month] . '/' . ($dayOfMonth) . '/' . $year;
    my $tomorrow = $months[$month] . '/' . ($dayOfMonth + 1) . '/' . $year;
    my $type1    = 'install';
    my $type2    = 'removal';

    my $id1 = $Key . $Code . $time . $type1;
    my $id2 = $Key . $Code . $time . $type2;
    my $id3 = $Key . $Code . $tomorrow . $type1;
    my $id4 = $Key . $Code . $tomorrow . $type2;
    _encrypt(\$id1);
    _encrypt(\$id2);
    _encrypt(\$id3);
    _encrypt(\$id4);

    my $rettrue;
    if ($ircode eq $id1) {
        if ($rettrue) {
            return 0;
        } else {
            $rettrue = 1;
        }
    } ## end if ($ircode eq $id1)
    if ($ircode eq $id2) {
        if ($rettrue) {
            return 0;
        } else {
            $rettrue = 1;
        }
    } ## end if ($ircode eq $id2)
    if ($ircode eq $id3) {
        if ($rettrue) {
            return 0;
        } else {
            $rettrue = 1;
        }
    } ## end if ($ircode eq $id3)
    if ($ircode eq $id4) {
        if ($rettrue) {
            return 0;
        } else {
            $rettrue = 1;
        }
    } ## end if ($ircode eq $id4)
    if ($rettrue) {
        return 'valid';
    } else {
        return 'invalid';
    }
} ## end sub _isValidInstallRemovalCode

##################################################################
#### Subroutine: _makeKey ########################################
##################################################################
# Takes a reference to the key variable.  It uses the sha384_hex #
# encryption algorithm to encrypt the string.  It uses the #######
# following algorithm: convert the ASCII to the Decimal Code, ####
# multiply the Decimal Codes of the first two elements and #######
# divide by the third.  It repeats for the length of the 96 ######
# characters. ####################################################
##################################################################

sub _makeKey {
    my $key = shift;
    ${$key} = sha384_hex(${$key});
    _fix($key);
    for (0 .. 2) {
        ${$key} = sha384_hex(${$key});
    }
    my @keychain = split(q{}, ${$key});
    my @newkey = ();
    ${$key} = q{};
    for (my $i = 0, my $j = 1, my $k = 2 ; $k <= $#keychain ; $i += 3, $j += 3, $k += 3) {
        ${$key} .= chr(round(ord($keychain[$i]) * ord($keychain[$j]) / ord($keychain[$k])));
    }
} ## end sub _makeKey

######################################################################
#### Subroutine: _makeReadable #######################################
######################################################################
# Converts text delivered by reference to ASCII Printable ############
# characters (except spaces [32], semicolons [59] single quote [39] ##
# [33-126, not 39 or 59]). It alters the  decimal values of the ######
# characters to characters within this range by subtracting 126, 33, #
# or adding 33 to the decimal number if it is really above of range, #
# above of range, or really below range. #############################
######################################################################

sub _makeReadable {
    my $encrypted_string = shift;
    _fix($encrypted_string);
    my @vals;
    my @chars = split(q{}, ${$encrypted_string});
    my $tempval = 0;
    foreach my $char (@chars) {
        $tempval = ord($char);
        my $continue = 0;
        until ($continue == 5) {
            $continue = 0;
            if (   $tempval == 60
                || $tempval == 62
                || $tempval == 38
                || $tempval == 59) {
                $tempval = reverse($tempval);
            } else {
                $continue++;
            }
            if ($tempval > 159) {
                while ($tempval > 159) {
                    $tempval -= 126;
                }
            } else {
                $continue++;
            }
            if (($tempval > 126) && ($tempval <= 159)) {
                while (($tempval > 126) && ($tempval <= 159)) {
                    $tempval -= 33;
                }
            } else {
                $continue++;
            }
            if (($tempval < 33) && ($tempval != 0)) {
                while (($tempval < 33) && ($tempval != 0)) {
                    $tempval += 33;
                }
            } else {
                $continue++;
            }
            if ($tempval == 39) {
                $tempval = 93;
            } else {
                $continue++;
            }
        } ## end until ($continue == 5)
        push(@vals, $tempval);
    } ## end foreach my $char (@chars)
    @chars = map {chr} @vals;
    ${$encrypted_string} = join(q{}, @chars);
    ${$encrypted_string} =~ s/\0//g;
} ## end sub _makeReadable

#####################################################
#### Subroutine: _ragnarokObliterationProtocol ######
#####################################################
# For right now, this is a simple while true, print #
# "OBLITERATING..." loop.  Eventually, this can be ##
# modified to be a destruction algorithm. ###########
#####################################################

sub _ragnarokObliterationProtocol {
    print 'OBLITERATING...';
    if (-d "mod.xml") {
        unlink("mod.xml");
        croak("Authentication string was inconsistent.  I will not take the chance that the module was compromised.  I have obliterated the mod.xml and refuse to honor it's request.");

    } else {
        croak("Keep lies, self-deceit, anger and violence from your hearts, for these are dead weights, and crush the life out of you...");
    }
}

########################################################
#### Subroutine: _ragnarokPrevention ###################
########################################################
# Takes a reference to the string to encrypt as the ####
# sole argument.  It uses the Rijndael (AES) algorithm #
# to encrypt a string using the following algorithm: ###
# rijndael encryption, append the key, reverse the #####
# decimal codes of each character, reverse the string, #
# and run the _makeReadable subroutine. ################
########################################################

sub _ragnarokPrevention {
    my $incomplete_encryption = shift;
    _makeReadable(\$Key);
    _fix(\$Key);
    _makeReadable($incomplete_encryption);
    _fix($incomplete_encryption);
    my $cipher = Crypt::Rijndael->new($Key, Crypt::Rijndael::MODE_CBC());
    my $crypted = $cipher->encrypt(${$incomplete_encryption});
    $crypted .= $Key;
    _reverseCharacters(\$crypted);
    $crypted = reverse($crypted);
    _makeReadable(\$crypted);
    ${$incomplete_encryption} = $crypted;
} ## end sub _ragnarokPrevention

#################################################
#### Subroutine: _removeTrailingLineBreak #######
#################################################
# Removes the trailing linebreak, if it exists, #
# from the input reference scalar. ##############
#################################################

sub _removeTrailingLineBreak {
    my $string = shift;
    ${$string} =~ s/\n$//;
}

####################################################
#### Subroutine: _reverseCharacters ################
####################################################
# Converts each character of the referenced scalar #
# into decimal, reverses the decimal ###############
# (i.e. 97 -> 79) and then, converts it back to ####
# a character (i.e. a -> 97 -> 79 -> O). ###########
####################################################

sub _reverseCharacters {
    my $encrypted_string = shift;
    my @chars            = ();
    my $tempstring;

    @chars = split(q{}, ${$encrypted_string});
    foreach (@chars) {
        $tempstring .= chr(reverse(ord($_)));
    }
    ${$encrypted_string} = $tempstring;
} ## end sub _reverseCharacters

##################################################
#### Subroutine: _shortenKey #####################
##################################################
# Takes a reference to the string (key) that #####
# needs to be shortened and the approximate ######
# desired key length. If combines the characters #
# using the same algorithm as _makeKey. ##########
##################################################

sub _shortenKey {
    my ($key, $key_size) = @_;
    _fix($key);
    while (length(${$key}) >= $key_size) {
        my @keychain = split(q{}, ${$key});
        my @newkey = ();
        ${$key} = q();
        for (my $i = 0, my $j = 1 ; $j <= $#keychain ; $i += 2, $j += 2) {
            ${$key} .= chr(round(ord($keychain[$i]) + ord($keychain[$j])));
        }
    } ## end while (length(${$key}) >=...)
} ## end sub _shortenKey

1;    # For use Ragnarok or require Ragnarok to return true

__END__

=pod
 
=head1 COPYRIGHT
 
 Copyright 2012 Z. Bornheimer.
 
 Permission is granted to copy, distribute and/or modify this 
 documentation under the terms of the GNU Free Documentation 
 License, Version 1.3 or any later version published by the 
 Free Software Foundation; with no Invariant Sections, with 
 no Front-Cover Texts, and with no Back-Cover Texts.
 
 Ragnarok itself is free software: you can redistribute it
 and/or modify it under the terms of the GNU Lesser General
 Public License as published by the Free Software Foundation, 
 either version 3 of the License, or any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
=cut
