#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

CV* func;
HV* data;

MODULE = Local::Stats		PACKAGE = Local::Stats		
INCLUDE: const-xs.inc

HV* pr()
	CODE:
		RETVAL = data;
	OUTPUT:
		RETVAL

double new(F)
		CV* F;
	CODE:
		func = F;
		data = newHV();

void add(metric_name, metric_value)
		const char* metric_name;
		int metric_value;
	PPCODE:
		HV* hash = data;
		U32 len = strlen(metric_name);
		
		if(hv_exists(data, metric_name, len)) {
			SV** metric_ptr = hv_fetch(data, metric_name, len, 0);
			HV* metric = (HV*)SvRV(*metric_ptr);
			if(hv_exists(metric, "cnt", 3)) {
				int cnt = SvIV( *hv_fetch(metric, "cnt", 3, 0) ); 
				hv_store(metric, "cnt", 3, newSViv(cnt+1), 0);
			}
			if(hv_exists(metric, "max", 3)) {
				int max = SvIV( *hv_fetch(metric, "max", 3, 0) ); 
				if(metric_value > max)
					hv_store(metric, "max", 3, newSViv(metric_value), 0);
			}
			if(hv_exists(metric, "min", 3)) {
				int min = SvIV( *hv_fetch(metric, "min", 3, 0) ); 
				if(metric_value < min)
					hv_store(metric, "min", 3, newSViv(metric_value), 0);
			}
			if(hv_exists(metric, "sum", 3)) {
				int sum = SvIV( *hv_fetch(metric, "sum", 3, 0) ); 
				hv_store(metric, "sum", 3, newSViv(sum + metric_value), 0);
			}				
			
		} else {
			ENTER; SAVETMPS; PUSHMARK(SP);
			int count = call_sv((SV*)func, G_ARRAY|G_NOARGS);
			SPAGAIN;
			HV* metric = newHV();
			int flag = 0;
			while(count-->0) {
				char *key = POPp;
				flag |= 1<<(key[0]-'a');
				U32 key_len = strlen(key);
				if( !strcmp(key, "avg") ) {
					hv_store(metric, "cnt", 3, newSViv(1), 0 );
					hv_store(metric, "sum", 3, newSViv(metric_value), 0 );					
				} else {
					int val_num = 1;
					if( strcmp(key, "cnt") ) val_num = metric_value;
					SV* val = newSViv(val_num);
					hv_store(metric, key, key_len, val, 0);
				}
			}
			hv_store(metric, "flag", 4, newSViv(flag), 0 );
			hv_store(data, metric_name, len, newRV((SV*)metric), 0);
		}

HV* stat()
	PPCODE:
		I32 count_keys = hv_iterinit(data);
		for (I32 i = 0; i < count_keys; i++) {
			char *key;
			I32 key_length = 0;
			HV *metric = SvRV( hv_iternextsv(data, &key, &key_length) );
			int flag = SvIV( *hv_fetch(metric, "flag", 4, 0) );
			if(! flag) {
				hv_delete(data, key, strlen(key), 0); //если метрика пустая
			} else {
				if( flag & 1<<('a' - 'a') ) {	//если в результирующей метрике есть поле 'avg'
					int cnt = SvIV( *hv_fetch(metric, "cnt", 3, 0) );
					int sum = SvIV( *hv_fetch(metric, "sum", 3, 0) );
					
					hv_store(metric, "avg", 3, newSViv(sum / cnt), 0 );
					
					if(! (flag & 1<<('c' - 'a')) )	//если в результирующей метрике не должно быть поля 'cnt'
						hv_delete(metric, "cnt", 3, 0);
					if(! (flag & 1<<('s' - 'a')) )	//если в результирующей метрике не должно быть поля 'sum'
						hv_delete(metric, "sum", 3, 0);
				}
				hv_delete(metric, "flag", 4, 0);
			}		  
		}
		XPUSHs(newRV( (SV*)data) );
		data = newHV();

