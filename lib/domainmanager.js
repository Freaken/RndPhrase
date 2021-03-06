#ifndef __DOMAIN_MANAGER__
#define __DOMAIN_MANAGER__


#include "lib/common.js"
#include "data/suffix-list.js"

rndphrase.DomainManager.get_host = function (domain) {
    // Try to use Firefox' built in list
    if (typeof(Components) !== "undefined") {
        var host,
            mozComponent;

        try {
            mozComponent = Components.classes["@mozilla.org/network/effective-tld-service;1"];
        } catch(err) {
            // security exception
        }

        if (mozComponent && mozComponent.getService) {
            try { // getBaseDomainFromHost may throw
                host = mozComponent.
                    getService(Components.interfaces.nsIEffectiveTLDService).
                    getBaseDomainFromHost(domain);
            } catch(err) {}
            if (host) {
                return host;
            }
        }
    }
    // Fall back to own list
    var suffixRegex = new RegExp("([^\\.]+\\.(?:" + rndphrase.DomainManager.SUFFIX_LIST.replace(/\./g, "\\.") + "|[a-z]+))$","i");
    return domain.match(suffixRegex)[0];
};
rndphrase.DomainManager.has_host = function (domain) {
    var host;
    try {
        host = rndphrase.DomainManager.get_host(domain);
    } catch(err) {
        return false;
    }
    return host.indexOf(".") != -1;
};

#endif