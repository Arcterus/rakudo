role Perl6::Metamodel::MROBasedMethodDispatch {
    # While we normally end up locating methods through the method cache,
    # this is here as a fallback.
    method find_method($obj, $name) {
        my %methods;
        for self.mro($obj) {
            %methods := $_.HOW.method_table($_);
            if pir::exists(%methods, $name) {
                return %methods{$name}
            }
        }
        my %submethods := $obj.HOW.submethod_table($obj);
        if pir::exists(%submethods, $name) {
            return %submethods{$name}
        }
        pir::can__IPs(self, 'find_method_fallback') ??
            self.find_method_fallback($obj, $name) !!
            pir::null__P();
    }
    
    method publish_method_cache($obj) {
        # Walk MRO and add methods to cache, unless another method
        # lower in the class hierarchy "shadowed" it.
        my %cache;
        for self.mro($obj) {
            my %methods := $_.HOW.method_table($_);
            for %methods {
                unless %cache{$_.key} {
                    %cache{$_.key} := $_.value;
                }
            }
        }
        
        # Also add submethods.
        my %submethods := $obj.HOW.submethod_table($obj);
        for %submethods {
            %cache{$_.key} := $_.value;
        }
        
        pir::publish_method_cache($obj, %cache)
    }
}
