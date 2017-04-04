my $max_child = 3;
my ($r, $w);
    pipe($r, $w);
    defined(my $child_pid = fork()) or die "can not fork";
   	if($child_pid){
   		close($w);
   		for(1..12){
	   		my $data;
			read($r, $data,4);
			$data = unpack('L',$data);
			print $data;	
			print " ";
   		}
   		close($r);
   	}else{
   		close($r);
   		for my $num_child(0..$max_child - 1) {
   			defined(my $child = fork()) or die "can not fork";
   			if($child){
   				next;	
   			}else{
   				print $w pack('L',1);
   				sleep(1);
   				print $w pack('L',2);
   				sleep(1);
				print $w pack('L',3);
   				sleep(1);
   				print $w pack('L',4);
   				sleep(1);
   				exit;   							
   			} 		
   		}
   		close($w);
   		exit;
   	}
