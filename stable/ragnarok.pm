#!/usr/bin/perl

=pod

=head1 NAME
 
 ragnarok.pm - The Ragnarok Encryption Module
 
=head1 DESCRIPTION
 
 The Ragnarok Prevention Module is a part of the ANUBIS Package.
 It contains the encrption algorithm for ANUBIS API.
 
=head1 ARGUMENTS
 
 The Ragnarok Prevention Module accepts the following arguments:
 
=over 4
 
=item C<aboutkey=<string>>
 
=item C<aboutcode=<string>>
 
=item C<generate=<string>>
 
=over 4
 
=item C<key>
 
=item C<code>
 
=item C<proof>
 
=item C<installcode>
 
=item C<removalcode>
 
=back
 
=item C<ircode=<string>>
 
=item C<key=<string>>
 
=item C<code=<string>>
 
=item C<proof=<string>>
 
=item C<validator>
 
=head1 API
 
 The Ragnarok Encryption Module has an API that consists
 of the following functions:
 
=over 4

=item C<setCode_api($)>
 
=item C<setKey_api($)>
 
=item C<setProof_api($)>
 
=item C<setIRCode_api($)>
  
=item C<generatekey($)>
 
=item C<generatecode($)>
 
=item C<generateproof()>
 
=item C<generateproof_api($$)>

=item C<generateircode()>
 
=item C<isValidInstallRemovalCode($)>
 
=back

=head1 FUNCTION DOCUMENTATION
 
=cut

package Ragnarok;

use strict;
use warnings;
use Crypt::Rijndael;
use Digest::SHA qw(sha384_hex);
use Math::Round;
use Getopt::Long;
use diagnostics-verbose;

my (
    $Key,       $Code,        $Proof,        $aboutkey,
    $aboutcode, $installcode, $removalcode,  $validator,
    $IRcode,    $generatekey, $generatecode, $generateproof,
   );

use Readonly;
Readonly my $ITERATION_NUMBER => 13;
Readonly my $AVERAGE_KEY_SIZE => 400;

GetOptions(
    'aboutkey=s'  => \$aboutkey,
    'aboutcode=s' => \$aboutcode,
    'key=s'       => \$Key,
    'code=s'      => \$Code,
    'proof=s'     => \$Proof,
    'validator'   => \$validator,
    'ircode=s'    => \$IRcode,
    'generate=s'  => sub {
        my ($option, $value) = @_;

        my %generateHash = (
                            'key'         => \$generatekey,
                            'code'        => \$generatecode,
                            'proof'       => \$generateproof,
                            'installcode' => \$installcode,
                            'removalcode' => \$removalcode,
                           );

        if ($generateHash{$value}) {
            ${$generateHash{$value}} = 1;
        } else {

            # Do Nothing
        }
    }
);

MAIN: {
    exit unless (&areValidOptions());

    &makeKey(\$Key) if $Key;

    &basicAuthentication()
      unless ($generatekey || $generatecode || $generateproof);

    print &generatekey($aboutkey) if ($generatekey && $aboutkey);
    print &generatecode($aboutcode)
      if ($generatecode && $Key && $aboutcode);
    print &generateproof() if $generateproof;
    print &generateircode() if ($installcode || $removalcode);
    print &isValidInstallRemovalCode($IRcode) if ($validator && $IRcode);

} ## end MAIN:

=pod
 
=head2 B<basicAuthentication>
 
 Takes no argument.  The prompter checks to see if the
 key, code, and/or proof were set via argument and, if not,
 asks for that information.  It will make sure that the accessor
 has a properly matching key, code, and proof strings.  If they
 match, the basicAuthentication function exits otherwise it sends
 itself into an infinite loop with the word "OBLITERATING..."
 appending itself to the output of the program.

=cut

sub basicAuthentication() {
    my ($badAttempts, $continue, $obliterate);
    $badAttempts = 0;
    until ($continue) {
        unless ($Key) {
            print 'Please enter the Ragnarok Prevention Module Unlock Key: ';
            chomp($Key = <STDIN>);
        }

        unless ($obliterate) {
            unless ($Code) {
                print 'Please enter the Ragnarok Prevention Code: ';
                $Code = <STDIN>;
                removeTrailingLineBreak(\$Code);
            }
            &fix(\$Code);
            my $data = $Code;

            unless ($Proof) {
                print 'Please enter the Ragnarok Prevention Module ',
                  'Proof of Authentication Now: ';
                my $Proof = <STDIN>;
                removeTrailingLineBreak(\$Proof);
            } ## end unless ($Proof)

            &encrypt(\$data);

            if ($Proof eq $data) {
                print 'Ragnarok Prevention Module Authentication Successful.';
                my $exitloop = 'yes';

            } else {
                $badAttempts++;
                print 'Ragnarok Prevention Module Authentication FAILURE.  ',
                  'The Ragnarok Obliteration Protocol will be activated in ',
                  ($ITERATION_NUMBER - $badAttempts), " more bad attemps.\n";
            } ## end else [ if ($Proof eq $data) ]

            if ($badAttempts >= $ITERATION_NUMBER) {
                my $exitloop = 'yes';
                ragnarokObliterationProtocol();
            }
        } else {
            for (0 .. (1000000 - 1)) {
                print 'Initiating the RAGNAROK OBLITERATION PROTOCOL...';
            }
            &ragnarokObliterationProtocol();
        } ## end else
    } ## end until ($continue)
} ## end sub basicAuthentication

=pod

=head2 B<encrypt>
 
 Takes one argument, a reference to the string to
 encrypt. This runs the ragnarokPrevention subroutine
 and,therefore, the encryption algorithm.

=cut

sub encrypt(\$) {
    my $string = shift;
    for (0 .. ($ITERATION_NUMBER - 1)) {
        &ragnarokPrevention($string);
    }
} ## end sub encrypt(\$)

=pod

=head2 B<fix>
 
 Takes one argument, a reference to the string whose
 length needs to be a multiple of 16 bytes.  This
 subroutine works by appending the null byte to the
 original string after calculating how many it needs
 to append via basic arithmatic.
 
=cut

sub fix(\$) {
    my $data   = shift;
    my $length = length(${$data});
    while ($length >= 16) {
        $length -= 16;
    }
    ${$data} .= ("\0" x (16 - $length)) unless $length == 0;
} ## end sub fix(\$)

=pod

=head2 B<generatecode>
 
 generatecode takes one argument, the $aboutcode
 string. It is also necessary for the key to be defined
 otherwise, it is unable to generate the code.

=cut

sub generatecode($) {
    my $aboutcode = shift;
    my $code      = generatekey($aboutcode);
    &encrypt(\$code);
    &shortenKey(\$code);
    &makeReadable(\$code);
    return $code;
} ## end sub generatecode($)

=pod

=head2 generatekey
 
 generatekey takes one argument, the $aboutkey string.
 It encrypts the $aboutkey string and uses that as both
 the encrypting key and data.  It encrypts the key with
 the key as its own salt.
 
=cut

sub generatekey($) {
    my $key = shift;
    &makeKey(\$key);
    $Key = $key;
    &encrypt(\$key);
    &shortenKey(\$key);
    &makeReadable(\$key);
    $Key = $key;
    return $key;
} ## end sub generatekey($)

=pod
 
=head2 generateircode
 
 generateircode requires that the $Key and $Code be set
 otherwise it will fail.  It generates the install/removal
 code necessary to install or remove a server from the ANUBIS
 server list.  Each code fails after the date differs too much
 from the date that is encrypted within the string.

=cut

sub generateircode() {
    exit unless defined($Key && $Code);
    my (
        $second,     $minute,    $hour,
        $dayOfMonth, $month,     $yearOffset,
        $dayOfWeek,  $dayOfYear, $daylightSavings
       ) = localtime();
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
    &encrypt(\$id);
    return $id;
} ## end sub generateircode

=pod
 
=head2 generateproof
 
 Generates the proof via encrypting the code
 with the key as the salt.
 
=cut

sub generateproof() {
    my $data = $Code;
    &fix(\$Code);
    &encrypt(\$data);
    &makeReadable(\$data);
    return $data;
} ## end sub generateproof

=pod
 
=head2 generateproof_api
 
 Generates the proof via encrypting the second argument
 with the first argument as the salt.  _API allows both the
 salt and data to be given as arguments to the subroutine.
 
=cut

sub generateproof_api($$) {
    my ($key, $code) = @_;
    &fix(\$key);
    &fix(\$Code);
    my $tempKey = $Key;
    $Key = $key;
    &encrypt(\$code);
    $Key = $tempKey;
    &makeReadable(\$code);
    return $code;
}

=pod

=head2 isValidInstallRemovalCode
 
 This subroutine checks to see if the ir code
 is valid not only in general, but also for this
 moment in time.  It generates all the possiblities
 and compares them to the string given.  The argument
 to the function is the ircode.
 
=cut

sub isValidInstallRemovalCode() {
    my $ircode = shift;
    my (
        $second,     $minute,    $hour,
        $dayOfMonth, $month,     $yearOffset,
        $dayOfWeek,  $dayOfYear, $daylightSavings
       ) = localtime();
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
    &encrypt(\$id1);
    &encrypt(\$id2);
    &encrypt(\$id3);
    &encrypt(\$id4);

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
} ## end sub isValidInstallRemovalCode

=pod

=head2 makeKey
 
 Takes a reference to the key variable.  It uses the sha384_hex
 encryption algorithm to encrypt the string.  It uses the
 following algorithm: convert the ASCII to the Decimal Code,
 multiply the Decimal Codes of the first two elements and
 divide by the third.  It repeats for the length of the 96
 characters.
 
=cut

sub makeKey(\$) {
    my $key = shift;
    ${$key} = sha384_hex(${$key});
    &fix($key);
    for (0 .. 2) {
        ${$key} = sha384_hex(${$key});
    }
    my @keychain = split(q{}, ${$key});
    my @newkey = ();
    ${$key} = q{};
    for (my $i = 0, my $j = 1, my $k = 2 ;
         $k <= $#keychain ;
         $i += 3, $j += 3, $k += 3) {
        ${$key} .= chr(
             round(ord($keychain[$i]) * ord($keychain[$j]) / ord($keychain[$k]))
        );
    } ## end for (my $i = 0, my $j =...)
} ## end sub makeKey(\$)

=pod
 
=head2 makeReadable
 
 Converts text delivered by reference to ASCII Printable
 characters (except spaces [32] and the single quote [39] [33-126, not 39]).
 It alters the  decimal values of the characters to characters
 within this range by subtracting 126, 33, or adding 33 to the
 decimal number if it is really above of range, 
 above of range, or really below range.
 
=cut

sub makeReadable(\$) {
    my $encrypted_string = shift;
    &fix($encrypted_string);
    my @vals;
    my @chars = split(q{}, ${$encrypted_string});
    my $tempval = 0;
    foreach my $char (@chars) {
        $tempval = ord($char);
        if ($tempval > 159) {
            while ($tempval > 159) {
                $tempval -= 126;
            }
        }
        if (($tempval > 126) && ($tempval < 159)) {
            while (($tempval > 126) && ($tempval < 159)) {
                $tempval -= 33;
            }
        }
        if (($tempval < 33) && ($tempval != 0)) {
            while (($tempval < 33) && ($tempval != 0)) {
                $tempval += 33;
            }
        }
        if ($tempval == 39) {
            $tempval = 93;
        }
        push(@vals, $tempval);
    } ## end foreach my $char (@chars)
    @chars = map {chr} @vals;
    ${$encrypted_string} = join(q{}, @chars);
} ## end sub makeReadable(\$)

=pod
 
=head2 ragnarokObliterationProtocol
 
 For right now, this is a simple while true, print
 "OBLITERATING..." loop.  Eventually, this can be
 modified to be a destruction algorithm.

=cut

sub ragnarokObliterationProtocol() {
    while (1) {
        print 'OBLITERATING...';
    }
}

=pod
 
=head2 ragnarokPrevention
 
 Takes a reference to the string to encrypt as the
 sole argument.  It uses the Rijndael (AES) algorithm
 to encrypt a string using the following algorithm:
 rijndael encryption, append the key, reverse the
 decimal codes of each character, reverse the string,
 and run the "makeReadable" subroutine.
 
=cut

sub ragnarokPrevention(\$) {
    my $incomplete_encryption = shift;
    &makeReadable(\$Key);
    &fix(\$Key);
    &fix($incomplete_encryption);
    &makeReadable($incomplete_encryption);
    my $cipher = Crypt::Rijndael->new($Key, Crypt::Rijndael::MODE_CBC());
    my $crypted = $cipher->encrypt(${$incomplete_encryption});
    $crypted .= $Key;
    reverseCharacters(\$crypted);
    $crypted = reverse($crypted);
    &makeReadable(\$crypted);
    ${$incomplete_encryption} = $crypted;
} ## end sub ragnarokPrevention(\$)

=pod

=head2 removeTrailingLineBreak
 
 Removes the trailing linebreak, if it exists,
 from the input reference scalar.
 
=cut

sub removeTrailingLineBreak(\$) {
    my $string = shift;
    ${$string} =~ s/\n$//;
}

=pod
 
=head2 reversCharacters
 
 Converts each character of the referenced scalar
 into decimal, reverses the decimal 
 (i.e. 97 -> 79) and then, converts it back to
 a character (i.e. a -> 97 -> 79 -> O).

=cut

sub reverseCharacters(\$) {
    my $encrypted_string = shift;
    my @chars            = ();
    my $tempstring;

    @chars = split(q{}, ${$encrypted_string});
    foreach (@chars) {
        $tempstring .= chr(reverse(ord($_)));
    }
    ${$encrypted_string} = $tempstring;
} ## end sub reverseCharacters(\$)

=pod
 
=head2 setAboutCode_api
 
 Sets the aboutcode string via argument.  Part of the API function set.
 
=cut

sub setAboutCode_api($) {
    $aboutcode = shift;
}

=pod
 
=head2 setAboutKey_api
 
 Sets the aboutkey string via argument.  Part of the API function set.
 
=cut

sub setAboutKey_api($) {
    $aboutkey = shift;
}

=pod
 
=head2 setCode_api
 
 Sets the code via argument.  Part of the API function set.
 
=cut

sub setCode_api($) {
    $Code = shift;
}

=pod
 
=head2 setKey_api
 
 Sets the key via argument.  Part of the API function set.

=cut

sub setKey_api($) {
    $Key = shift;
}

=pod
 
=head2 setProof_api
 
 Sets the proof via argument.  Part of the API function set.

=cut

sub setProof_api($) {
    $Proof = shift;
}

sub setIRCode_api($) {
    $IRcode = shift;
}

=pod
 
=head2 shortenKey
 
 Takes a reference to the string (key) that
 needs to be shortened.  If combines the 

=cut

sub shortenKey(\$) {
    my $key = shift;
    &fix($key);
    while (length(${$key}) >= $AVERAGE_KEY_SIZE) {
        my @keychain = split(q{}, ${$key});
        my @newkey = ();
        ${$key} = q();
        for (my $i = 0, my $j = 1 ; $j <= $#keychain ; $i += 2, $j += 2) {
            ${$key} .= chr(round(ord($keychain[$i]) + ord($keychain[$j])));
        }
    } ## end while (length(${$key}) >=...)
} ## end sub shortenKey(\$)

=pod

=head2 areValidOptions()
 
 This subroutine checks to see if the options given to
 the commandline are in the proper pairs.  If the pairs
 are not defined, the subroutine returns 0 and the program
 exits without warning.
 
=cut

sub areValidOptions() {

    my %correctCommandCombinations = (
           'generatekey_aboutkey' => defined($generatekey && $aboutkey),
           'generatecode_aboutcode_key' =>
             defined($generatecode && $aboutcode && $Key),
           'generateproof_key_code' => defined($generateproof && $Key && $Code),
           'validator_ircode' => defined($validator && $IRcode),
           'nothing_defined' =>
             !defined(
                           $generatekey
                        && $generatecode
                        && $generateproof
                        && $aboutkey
                        && $aboutcode
                        && $validator
                        && $IRcode
                     ),
    );

    foreach my $key (%correctCommandCombinations) {
        return 1 if ($correctCommandCombinations{$key});
    }

    return 0;

} ## end sub areValidOptions

__END__

=pod
 
=head1 COPYRIGHT
 
 Copyright 2011 Z. Bornheimer and The Technetronics Group.
 
 Permission is granted to copy, distribute and/or modify this 
 document under the terms of the GNU Free Documentation 
 License, Version 1.3 or any later version published by the 
 Free Software Foundation; with no Invariant Sections, with 
 no Front-Cover Texts, and with no Back-Cover Texts.
 
=cut
