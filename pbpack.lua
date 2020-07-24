local pbpack = {
    pkgname_ = "Cmd.",
    pbfile_ = "",
    init_ = false
}

function pbpack.init(conf)
    if pbpack.init_ == true then
        return
    end
    pbpack.pkgname_ = conf.pkg
    pbpack.pbfile_ = conf.pbfile
    local filedata = cc.GameUtils:getFileData(pbpack.pbfile_)
    if not filedata then
        log.error("failed:"..pbpack.pbfile_)
        return
    end
    protobuf.register(filedata)
    pbpack.init_ = true
end

function pbpack.pack(msg,mtype)
    if pbpack.init_ == false then
        return nil
    end
    local msgtype = pbpack.pkgname_..mtype
    local status,result = xpcall(protobuf.encode,__G__TRACKBACK__,msgtype,msg)
    if status then
        return result
    end
    log.error("failed type:%s,error:%s",msgtype,tostring(result))
    return nil
end

function pbpack.unpack(bin,mtype)
    if pbpack.init_ == false then
        return nil
    end
    local msgtype = pbpack.pkgname_..mtype
    local status,result = xpcall(protobuf.decode,__G__TRACKBACK__,msgtype,bin)
    if status then
        if type(result) == "table" then
            return result
        else
            log.error("failed type:%s",msgtype)
            return nil
        end
    end
    log.error("failed type:%s,error:%s",msgtype,tostring(result))
    return nil
end

function pbpack.newmsg(msgtype)
    return {
        enctype__="pb",
        msgtype__=msgtype
    }
end

function pbpack.check(typename)
    if pbpack.init_ == false then
        return false
    end
    return protobuf.check(pbpack.pkgname_..typename)
end

return pbpack

