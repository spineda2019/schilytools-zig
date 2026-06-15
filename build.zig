const std = @import("std");

const SourceFile = struct {
    name: []const u8,
    directory: []const u8,
};

const CFiles = struct {
    hfs_iso: []const SourceFile,
    mkisofs: []const SourceFile,
    schily: []const SourceFile,
    find: []const SourceFile,
    siconv: []const SourceFile,
    scgcmd: []const SourceFile,
    file: []const SourceFile,
    scg: []const SourceFile,
    rscg: []const SourceFile,
    cdrdeflt: []const SourceFile,
    deflt: []const SourceFile,
    mdigest: []const SourceFile,
};

const CFlags = struct {
    hfs_iso: []const []const u8,
    mkisofs: []const []const u8,
    schily: []const []const u8,
    find: []const []const u8,
    siconv: []const []const u8,
    scgcmd: []const []const u8,
    file: []const []const u8,
    scg: []const []const u8,
    rscg: []const []const u8,
    cdrdeflt: []const []const u8,
    deflt: []const []const u8,
    mdigest: []const []const u8,
};

const Modules = struct {
    hfs_iso: *std.Build.Module,
    mkisofs: *std.Build.Module,
    schily: *std.Build.Module,
    find: *std.Build.Module,
    siconv: *std.Build.Module,
    scgcmd: *std.Build.Module,
    file: *std.Build.Module,
    scg: *std.Build.Module,
    rscg: *std.Build.Module,
    cdrdeflt: *std.Build.Module,
    deflt: *std.Build.Module,
    mdigest: *std.Build.Module,

    fn init(b: *std.Build) Modules {
        var this: Modules = undefined;
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});

        inline for (comptime std.meta.fieldNames(Modules)) |field_name| {
            @field(this, field_name) = b.createModule(.{
                .link_libc = true,
                .link_libcpp = false,
                .target = target,
                .optimize = optimize,
            });
        }

        return this;
    }

    fn setupCFiles(
        this: *const Modules,
        b: *std.Build,
        comptime files: *const CFiles,
        comptime flags: *const CFlags,
    ) void {
        //
        inline for (comptime std.meta.fieldNames(Modules)) |field_name| {
            const mod: *std.Build.Module = @field(this, field_name);
            const c_files: []const SourceFile = @field(files, field_name);
            const c_flags: []const []const u8 = @field(flags, field_name);

            for (c_files) |file| {
                const lp = b.path(file.directory).join(b.allocator, file.name) catch @panic("OOM");
                mod.addCSourceFile(.{
                    .language = .c,
                    .file = lp,
                    .flags = c_flags,
                });
            }
        }
    }
};

const Binaries = struct {
    hfs_iso: *std.Build.Step.Compile,
    mkisofs: *std.Build.Step.Compile,
    schily: *std.Build.Step.Compile,
    find: *std.Build.Step.Compile,
    siconv: *std.Build.Step.Compile,
    scgcmd: *std.Build.Step.Compile,
    file: *std.Build.Step.Compile,
    scg: *std.Build.Step.Compile,
    rscg: *std.Build.Step.Compile,
    cdrdeflt: *std.Build.Step.Compile,
    deflt: *std.Build.Step.Compile,
    mdigest: *std.Build.Step.Compile,
};

const BuildSteps = struct {
    hfs_iso: *std.Build.Step,
    mkisofs: *std.Build.Step,
    schily: *std.Build.Step,
    find: *std.Build.Step,
    siconv: *std.Build.Step,
    scgcmd: *std.Build.Step,
    file: *std.Build.Step,
    scg: *std.Build.Step,
    rscg: *std.Build.Step,
    cdrdeflt: *std.Build.Step,
    deflt: *std.Build.Step,
    mdigest: *std.Build.Step,

    fn createSteps(b: *std.Build, binaries: *const Binaries) void {
        const install_step = b.getInstallStep();

        inline for (comptime std.meta.fieldNames(BuildSteps)) |field_name| {
            const step: *std.Build.Step = b.step(field_name, "Build " ++ field_name);
            const compile: *std.Build.Step.Compile = @field(binaries, field_name);
            const artifact_step = b.addInstallArtifact(compile, .{});
            step.dependOn(&artifact_step.step);
            install_step.dependOn(step);
        }
    }
};

const cfiles: CFiles = .{
    .hfs_iso = &.{
        .{ .name = "data.c", .directory = "libhfs_iso/" },
        .{ .name = "block.c", .directory = "libhfs_iso/" },
        .{ .name = "low.c", .directory = "libhfs_iso/" },
        .{ .name = "file.c", .directory = "libhfs_iso/" },
        .{ .name = "btree.c", .directory = "libhfs_iso/" },
        .{ .name = "node.c", .directory = "libhfs_iso/" },
        .{ .name = "record.c", .directory = "libhfs_iso/" },
        .{ .name = "volume.c", .directory = "libhfs_iso/" },
        .{ .name = "hfs.c", .directory = "libhfs_iso/" },
        .{ .name = "gdata.c", .directory = "libhfs_iso/" },
    },
    .mkisofs = &.{
        .{ .name = "mkisofs.c", .directory = "mkisofs/" },
        .{ .name = "tree.c", .directory = "mkisofs/" },
        .{ .name = "write.c", .directory = "mkisofs/" },
        .{ .name = "hash.c", .directory = "mkisofs/" },
        .{ .name = "rock.c", .directory = "mkisofs/" },
        .{ .name = "inode.c", .directory = "mkisofs/" },
        .{ .name = "udf.c", .directory = "mkisofs/" },
        .{ .name = "multi.c", .directory = "mkisofs/" },
        .{ .name = "joliet.c", .directory = "mkisofs/" },
        .{ .name = "match.c", .directory = "mkisofs/" },
        .{ .name = "name.c", .directory = "mkisofs/" },
        .{ .name = "eltorito.c", .directory = "mkisofs/" },
        .{ .name = "boot.c", .directory = "mkisofs/" },
        .{ .name = "isonum.c", .directory = "mkisofs/" },
        .{ .name = "scsi.c", .directory = "mkisofs/" },
        .{ .name = "apple.c", .directory = "mkisofs/" },
        .{ .name = "volume.c", .directory = "mkisofs/" },
        .{ .name = "desktop.c", .directory = "mkisofs/" },
        .{ .name = "mac_label.c", .directory = "mkisofs/" },
        .{ .name = "stream.c", .directory = "mkisofs/" },
        .{ .name = "ifo_read.c", .directory = "mkisofs/" },
        .{ .name = "dvd_file.c", .directory = "mkisofs/" },
        .{ .name = "dvd_reader.c", .directory = "mkisofs/" },
        .{ .name = "walk.c", .directory = "mkisofs/" },
    },
    .schily = &.{
        .{ .name = "cvmod.c", .directory = "libschily/stdio/" },
        .{ .name = "dat.c", .directory = "libschily/stdio/" },
        .{ .name = "fcons.c", .directory = "libschily/stdio/" },
        .{ .name = "fdown.c", .directory = "libschily/stdio/" },
        .{ .name = "fdup.c", .directory = "libschily/stdio/" },
        .{ .name = "ffileread.c", .directory = "libschily/stdio/" },
        .{ .name = "ffilewrite.c", .directory = "libschily/stdio/" },
        .{ .name = "fgetaline.c", .directory = "libschily/stdio/" },
        .{ .name = "fgetline.c", .directory = "libschily/stdio/" },
        .{ .name = "fgetstr.c", .directory = "libschily/stdio/" },
        .{ .name = "file_getraise.c", .directory = "libschily/stdio/" },
        .{ .name = "file_raise.c", .directory = "libschily/stdio/" },
        .{ .name = "fileclose.c", .directory = "libschily/stdio/" },
        .{ .name = "fileluopen.c", .directory = "libschily/stdio/" },
        .{ .name = "fileopen.c", .directory = "libschily/stdio/" },
        .{ .name = "filemopen.c", .directory = "libschily/stdio/" },
        .{ .name = "filepos.c", .directory = "libschily/stdio/" },
        .{ .name = "fileread.c", .directory = "libschily/stdio/" },
        .{ .name = "filereopen.c", .directory = "libschily/stdio/" },
        .{ .name = "fileseek.c", .directory = "libschily/stdio/" },
        .{ .name = "filesize.c", .directory = "libschily/stdio/" },
        .{ .name = "filestat.c", .directory = "libschily/stdio/" },
        .{ .name = "filewrite.c", .directory = "libschily/stdio/" },
        .{ .name = "flag.c", .directory = "libschily/stdio/" },
        .{ .name = "flush.c", .directory = "libschily/stdio/" },
        .{ .name = "fpipe.c", .directory = "libschily/stdio/" },
        .{ .name = "getdelim.c", .directory = "libschily/stdio/" },
        .{ .name = "niread.c", .directory = "libschily/stdio/" },
        .{ .name = "niwrite.c", .directory = "libschily/stdio/" },
        .{ .name = "nixread.c", .directory = "libschily/stdio/" },
        .{ .name = "nixwrite.c", .directory = "libschily/stdio/" },
        .{ .name = "openfd.c", .directory = "libschily/stdio/" },
        .{ .name = "peekc.c", .directory = "libschily/stdio/" },
        .{ .name = "fcons64.c", .directory = "libschily/stdio/" },
        .{ .name = "fdup64.c", .directory = "libschily/stdio/" },
        .{ .name = "fileluopen64.c", .directory = "libschily/stdio/" },
        .{ .name = "fileopen64.c", .directory = "libschily/stdio/" },
        .{ .name = "filemopen64.c", .directory = "libschily/stdio/" },
        .{ .name = "filepos64.c", .directory = "libschily/stdio/" },
        .{ .name = "filereopen64.c", .directory = "libschily/stdio/" },
        .{ .name = "fileseek64.c", .directory = "libschily/stdio/" },
        .{ .name = "filesize64.c", .directory = "libschily/stdio/" },
        .{ .name = "filestat64.c", .directory = "libschily/stdio/" },
        .{ .name = "openfd64.c", .directory = "libschily/stdio/" },
        .{ .name = "abspath.c", .directory = "libschily/" },
        .{ .name = "astoi.c", .directory = "libschily/" },
        .{ .name = "astoll.c", .directory = "libschily/" },
        .{ .name = "astoul.c", .directory = "libschily/" },
        .{ .name = "astoull.c", .directory = "libschily/" },
        .{ .name = "basename.c", .directory = "libschily/" },
        .{ .name = "breakline.c", .directory = "libschily/" },
        .{ .name = "checkerr.c", .directory = "libschily/" },
        .{ .name = "comerr.c", .directory = "libschily/" },
        .{ .name = "fcomerr.c", .directory = "libschily/" },
        .{ .name = "gtcomerr.c", .directory = "libschily/" },
        .{ .name = "fgtcomerr.c", .directory = "libschily/" },
        .{ .name = "chown.c", .directory = "libschily/" },
        .{ .name = "cmpbytes.c", .directory = "libschily/" },
        .{ .name = "cmpmbytes.c", .directory = "libschily/" },
        .{ .name = "cmpnullbytes.c", .directory = "libschily/" },
        .{ .name = "dirent.c", .directory = "libschily/" },
        .{ .name = "dirname.c", .directory = "libschily/" },
        .{ .name = "diropen.c", .directory = "libschily/" },
        .{ .name = "dlfcn.c", .directory = "libschily/" },
        .{ .name = "eaccess.c", .directory = "libschily/" },
        .{ .name = "error.c", .directory = "libschily/" },
        .{ .name = "gterror.c", .directory = "libschily/" },
        .{ .name = "faccessat.c", .directory = "libschily/" },
        .{ .name = "fchdir.c", .directory = "libschily/" },
        .{ .name = "fchmodat.c", .directory = "libschily/" },
        .{ .name = "fchownat.c", .directory = "libschily/" },
        .{ .name = "fconv.c", .directory = "libschily/" },
        .{ .name = "fdopendir.c", .directory = "libschily/" },
        .{ .name = "fexec.c", .directory = "libschily/" },
        .{ .name = "fillbytes.c", .directory = "libschily/" },
        .{ .name = "findinpath.c", .directory = "libschily/" },
        .{ .name = "findbytes.c", .directory = "libschily/" },
        .{ .name = "findline.c", .directory = "libschily/" },
        .{ .name = "fnmatch.c", .directory = "libschily/" },
        .{ .name = "format.c", .directory = "libschily/" },
        .{ .name = "fpoff.c", .directory = "libschily/" },
        .{ .name = "fprformat.c", .directory = "libschily/" },
        .{ .name = "fstatat.c", .directory = "libschily/" },
        .{ .name = "fstatat64.c", .directory = "libschily/" },
        .{ .name = "fstream.c", .directory = "libschily/" },
        .{ .name = "futimens.c", .directory = "libschily/" },
        .{ .name = "futimesat.c", .directory = "libschily/" },
        .{ .name = "getargs.c", .directory = "libschily/" },
        .{ .name = "getav0.c", .directory = "libschily/" },
        .{ .name = "geterrno.c", .directory = "libschily/" },
        .{ .name = "getexecpath.c", .directory = "libschily/" },
        .{ .name = "getfp.c", .directory = "libschily/" },
        .{ .name = "getgrent.c", .directory = "libschily/" },
        .{ .name = "getdtablesize.c", .directory = "libschily/" },
        .{ .name = "getdomainname.c", .directory = "libschily/" },
        .{ .name = "gethostname.c", .directory = "libschily/" },
        .{ .name = "getpagesize.c", .directory = "libschily/" },
        .{ .name = "getlogin.c", .directory = "libschily/" },
        .{ .name = "getnum.c", .directory = "libschily/" },
        .{ .name = "getxnum.c", .directory = "libschily/" },
        .{ .name = "gettnum.c", .directory = "libschily/" },
        .{ .name = "getxtnum.c", .directory = "libschily/" },
        .{ .name = "getperm.c", .directory = "libschily/" },
        .{ .name = "getpwent.c", .directory = "libschily/" },
        .{ .name = "getnstimeofday.c", .directory = "libschily/" },
        .{ .name = "gettimeofday.c", .directory = "libschily/" },
        .{ .name = "gid.c", .directory = "libschily/" },
        .{ .name = "handlecond.c", .directory = "libschily/" },
        .{ .name = "jsdprintf.c", .directory = "libschily/" },
        .{ .name = "jsprintf.c", .directory = "libschily/" },
        .{ .name = "jssnprintf.c", .directory = "libschily/" },
        .{ .name = "jssprintf.c", .directory = "libschily/" },
        .{ .name = "gtprintf.c", .directory = "libschily/" },
        .{ .name = "kill.c", .directory = "libschily/" },
        .{ .name = "lchmod.c", .directory = "libschily/" },
        .{ .name = "gethostid.c", .directory = "libschily/" },
        .{ .name = "linkat.c", .directory = "libschily/" },
        .{ .name = "lutimens.c", .directory = "libschily/" },
        .{ .name = "lxchdir.c", .directory = "libschily/" },
        .{ .name = "match.c", .directory = "libschily/" },
        .{ .name = "matchl.c", .directory = "libschily/" },
        .{ .name = "matchmb.c", .directory = "libschily/" },
        .{ .name = "matchmbl.c", .directory = "libschily/" },
        .{ .name = "matchw.c", .directory = "libschily/" },
        .{ .name = "matchwl.c", .directory = "libschily/" },
        .{ .name = "movebytes.c", .directory = "libschily/" },
        .{ .name = "movecbytes.c", .directory = "libschily/" },
        .{ .name = "mkdirat.c", .directory = "libschily/" },
        .{ .name = "mkdirs.c", .directory = "libschily/" },
        .{ .name = "mkfifo.c", .directory = "libschily/" },
        .{ .name = "mkfifoat.c", .directory = "libschily/" },
        .{ .name = "mkgmtime.c", .directory = "libschily/" },
        .{ .name = "mknodat.c", .directory = "libschily/" },
        .{ .name = "mkstemp.c", .directory = "libschily/" },
        .{ .name = "mem.c", .directory = "libschily/" },
        .{ .name = "jmem.c", .directory = "libschily/" },
        .{ .name = "fjmem.c", .directory = "libschily/" },
        .{ .name = "openat.c", .directory = "libschily/" },
        .{ .name = "openat64.c", .directory = "libschily/" },
        .{ .name = "ovstrcpy.c", .directory = "libschily/" },
        .{ .name = "permtostr.c", .directory = "libschily/" },
        .{ .name = "procnameat.c", .directory = "libschily/" },
        .{ .name = "putenv.c", .directory = "libschily/" },
        .{ .name = "raisecond.c", .directory = "libschily/" },
        .{ .name = "readlinkat.c", .directory = "libschily/" },
        .{ .name = "rename.c", .directory = "libschily/" },
        .{ .name = "renameat.c", .directory = "libschily/" },
        .{ .name = "resolvepath.c", .directory = "libschily/" },
        .{ .name = "saveargs.c", .directory = "libschily/" },
        .{ .name = "savewd.c", .directory = "libschily/" },
        .{ .name = "searchinpath.c", .directory = "libschily/" },
        .{ .name = "serrmsg.c", .directory = "libschily/" },
        .{ .name = "seterrno.c", .directory = "libschily/" },
        .{ .name = "setfp.c", .directory = "libschily/" },
        .{ .name = "setnstimeofday.c", .directory = "libschily/" },
        .{ .name = "sleep.c", .directory = "libschily/" },
        .{ .name = "snprintf.c", .directory = "libschily/" },
        .{ .name = "spawn.c", .directory = "libschily/" },
        .{ .name = "strcasecmp.c", .directory = "libschily/" },
        .{ .name = "strncasecmp.c", .directory = "libschily/" },
        .{ .name = "strcasemap.c", .directory = "libschily/" },
        .{ .name = "strcat.c", .directory = "libschily/" },
        .{ .name = "strcatl.c", .directory = "libschily/" },
        .{ .name = "strchr.c", .directory = "libschily/" },
        .{ .name = "strcmp.c", .directory = "libschily/" },
        .{ .name = "strcpy.c", .directory = "libschily/" },
        .{ .name = "strcspn.c", .directory = "libschily/" },
        .{ .name = "strdup.c", .directory = "libschily/" },
        .{ .name = "streql.c", .directory = "libschily/" },
        .{ .name = "strlen.c", .directory = "libschily/" },
        .{ .name = "strlcat.c", .directory = "libschily/" },
        .{ .name = "strlcatl.c", .directory = "libschily/" },
        .{ .name = "strlcpy.c", .directory = "libschily/" },
        .{ .name = "strncat.c", .directory = "libschily/" },
        .{ .name = "strncmp.c", .directory = "libschily/" },
        .{ .name = "strncpy.c", .directory = "libschily/" },
        .{ .name = "strndup.c", .directory = "libschily/" },
        .{ .name = "strnlen.c", .directory = "libschily/" },
        .{ .name = "strrchr.c", .directory = "libschily/" },
        .{ .name = "strspn.c", .directory = "libschily/" },
        .{ .name = "strstr.c", .directory = "libschily/" },
        .{ .name = "swabbytes.c", .directory = "libschily/" },
        .{ .name = "symlinkat.c", .directory = "libschily/" },
        .{ .name = "timegm.c", .directory = "libschily/" },
        .{ .name = "uid.c", .directory = "libschily/" },
        .{ .name = "unlinkat.c", .directory = "libschily/" },
        .{ .name = "uname.c", .directory = "libschily/" },
        .{ .name = "unsetenv.c", .directory = "libschily/" },
        .{ .name = "usleep.c", .directory = "libschily/" },
        .{ .name = "utimens.c", .directory = "libschily/" },
        .{ .name = "utimensat.c", .directory = "libschily/" },
        .{ .name = "vsnprintf.c", .directory = "libschily/" },
        .{ .name = "waitid.c", .directory = "libschily/" },
        .{ .name = "wcscat.c", .directory = "libschily/" },
        .{ .name = "wcscatl.c", .directory = "libschily/" },
        .{ .name = "wcschr.c", .directory = "libschily/" },
        .{ .name = "wcscmp.c", .directory = "libschily/" },
        .{ .name = "wcscpy.c", .directory = "libschily/" },
        .{ .name = "wcscspn.c", .directory = "libschily/" },
        .{ .name = "wcsdup.c", .directory = "libschily/" },
        .{ .name = "wcseql.c", .directory = "libschily/" },
        .{ .name = "wcslen.c", .directory = "libschily/" },
        .{ .name = "wcslcat.c", .directory = "libschily/" },
        .{ .name = "wcslcatl.c", .directory = "libschily/" },
        .{ .name = "wcslcpy.c", .directory = "libschily/" },
        .{ .name = "wcsncat.c", .directory = "libschily/" },
        .{ .name = "wcsncmp.c", .directory = "libschily/" },
        .{ .name = "wcsncpy.c", .directory = "libschily/" },
        .{ .name = "wcsndup.c", .directory = "libschily/" },
        .{ .name = "wcsnlen.c", .directory = "libschily/" },
        .{ .name = "wcsrchr.c", .directory = "libschily/" },
        .{ .name = "wcsspn.c", .directory = "libschily/" },
        .{ .name = "wcsstr.c", .directory = "libschily/" },
        .{ .name = "wctype.c", .directory = "libschily/" },
        .{ .name = "wcastoi.c", .directory = "libschily/" },
        .{ .name = "wdabort.c", .directory = "libschily/" },
        .{ .name = "zerobytes.c", .directory = "libschily/" },
    },
    .find = &.{
        .{ .name = "find.c", .directory = "libfind/" },
        .{ .name = "walk.c", .directory = "libfind/" },
        .{ .name = "fetchdir.c", .directory = "libfind/" },
        .{ .name = "cmpdir.c", .directory = "libfind/" },
        .{ .name = "find_misc.c", .directory = "libfind/" },
        .{ .name = "find_list.c", .directory = "libfind/" },
        .{ .name = "find_main.c", .directory = "libfind/" },
        .{ .name = "idcache.c", .directory = "libfind/" },
        .{ .name = "ptime.c", .directory = "libfind/" },
    },
    .siconv = &.{
        .{ .name = "sic_nls.c", .directory = "libsiconv/" },
    },
    .scgcmd = &.{
        .{ .name = "buffer.c", .directory = "libscgcmd/" },
        .{ .name = "inquiry.c", .directory = "libscgcmd/" },
        .{ .name = "modes.c", .directory = "libscgcmd/" },
        .{ .name = "modesense.c", .directory = "libscgcmd/" },
        .{ .name = "read.c", .directory = "libscgcmd/" },
        .{ .name = "readcap.c", .directory = "libscgcmd/" },
        .{ .name = "ready.c", .directory = "libscgcmd/" },
    },
    .file = &.{
        .{ .name = "file.c", .directory = "libfile/" },
        .{ .name = "apprentice.c", .directory = "libfile/" },
        .{ .name = "softmagic.c", .directory = "libfile/" },
    },
    .scg = &.{
        .{ .name = "scsitransp.c", .directory = "libscg/" },
        .{ .name = "scsihack.c", .directory = "libscg/" },
        .{ .name = "scsiopen.c", .directory = "libscg/" },
        .{ .name = "scgsettarget.c", .directory = "libscg/" },
        .{ .name = "scsierrs.c", .directory = "libscg/" },
        .{ .name = "scgtimes.c", .directory = "libscg/" },
        .{ .name = "scsihelp.c", .directory = "libscg/" },
        .{ .name = "scsiopts.c", .directory = "libscg/" },
        .{ .name = "rdummy.c", .directory = "libscg/" },
    },
    .rscg = &.{
        .{ .name = "scsi-remote.c", .directory = "librscg/" },
    },
    .cdrdeflt = &.{
        .{ .name = "cdrdeflt.c", .directory = "libcdrdeflt/" },
    },
    .deflt = &.{
        .{ .name = "default.c", .directory = "libdeflt/" },
    },
    .mdigest = &.{
        .{ .name = "md4.c", .directory = "libmdigest/" },
        .{ .name = "md5.c", .directory = "libmdigest/" },
        .{ .name = "rmd160.c", .directory = "libmdigest/" },
        .{ .name = "sha1.c", .directory = "libmdigest/" },
        .{ .name = "sha2.c", .directory = "libmdigest/" },
        .{ .name = "sha3.c", .directory = "libmdigest/" },
        .{ .name = "byte_order.c", .directory = "libmdigest/" },
        .{ .name = "blake2b.c", .directory = "libmdigest/" },
        .{ .name = "blake2s.c", .directory = "libmdigest/" },
    },
};

const cflags: CFlags = .{
    .mkisofs = &.{},
    .hfs_iso = &.{},
    .schily = &.{},
    .find = &.{},
    .siconv = &.{},
    .scgcmd = &.{},
    .file = &.{},
    .scg = &.{},
    .rscg = &.{},
    .cdrdeflt = &.{},
    .deflt = &.{},
    .mdigest = &.{},
};

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    const modules: Modules = .init(b);
    modules.setupCFiles(b, &cfiles, &cflags);

    modules.hfs_iso.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.hfs_iso.addSystemIncludePath(b.path("include/"));
    modules.hfs_iso.addCMacro("SCHILY_BUILD", "");
    modules.hfs_iso.addCMacro("APPLE_HYB", "");
    modules.hfs_iso.addCMacro("_GNU_SOURCE", "");
    const lib_hfs_iso = b.addLibrary(.{
        .name = "hfs_iso",
        .root_module = modules.hfs_iso,
        .linkage = .static,
    });

    modules.schily.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.schily.addSystemIncludePath(b.path("include/"));
    modules.schily.addSystemIncludePath(b.path("include/schily/"));
    modules.schily.addSystemIncludePath(b.path("libschily/stdio/"));
    modules.schily.addCMacro("SCHILY_BUILD", "");
    modules.schily.addCMacro("USE_SCANSTACK", "");
    modules.schily.addCMacro("PORT_ONLY", "");
    modules.schily.addCMacro("NO_GETLINE_COMPAT", "");
    modules.schily.addCMacro("_GNU_SOURCE", "");
    const lib_schily = b.addLibrary(.{
        .name = "schily",
        .root_module = modules.schily,
        .linkage = .static,
    });

    modules.find.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.find.addSystemIncludePath(b.path("include/"));
    modules.find.addSystemIncludePath(b.path("include/schily/"));
    modules.find.addCMacro("USE_LARGEFILES", "");
    modules.find.addCMacro("USE_ACL", "");
    modules.find.addCMacro("USE_XATTR", "");
    modules.find.addCMacro("USE_NLS", "");
    modules.find.addCMacro("USE_DGETTEXT", "");
    modules.find.addCMacro("TEXT_DOMAIN", "\"SCHILY_FIND\"");
    modules.find.addCMacro("SCHILY_PRINT", "");
    modules.find.addCMacro("_GNU_SOURCE", "");
    const lib_find = b.addLibrary(.{
        .name = "find",
        .root_module = modules.find,
        .linkage = .static,
    });

    modules.siconv.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.siconv.addSystemIncludePath(b.path("include/"));
    modules.siconv.addCMacro("SCHILY_BUILD", "");
    modules.siconv.addCMacro("SCHILY_PRINT", "");
    modules.siconv.addCMacro("USE_ICONV", "");
    modules.siconv.addCMacro("INS_BASE", "\"/opt/schily\"");
    modules.siconv.addCMacro("_GNU_SOURCE", "");
    const lib_siconv = b.addLibrary(.{
        .name = "siconv",
        .root_module = modules.siconv,
        .linkage = .static,
    });

    modules.scgcmd.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.scgcmd.addSystemIncludePath(b.path("include/"));
    modules.scgcmd.addSystemIncludePath(b.path("libscgcmd/"));
    modules.scgcmd.addSystemIncludePath(b.path("libscg/"));
    modules.scgcmd.addCMacro("SCHILY_BUILD", "");
    modules.scgcmd.addCMacro("USE_LARGEFILES", "");
    modules.scgcmd.addCMacro("SCHILY_PRINT", "");
    modules.scgcmd.addCMacro("_GNU_SOURCE", "");
    const lib_scgcmd = b.addLibrary(.{
        .name = "scgcmd",
        .root_module = modules.scgcmd,
        .linkage = .static,
    });

    modules.file.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.file.addSystemIncludePath(b.path("include/"));
    modules.file.addCMacro("SCHILY_BUILD", "");
    modules.file.addCMacro("SCHILY_PRINT", "");
    modules.file.addCMacro("_GNU_SOURCE", "");
    const lib_file = b.addLibrary(.{
        .name = "file",
        .root_module = modules.file,
        .linkage = .static,
    });

    modules.scg.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.scg.addSystemIncludePath(b.path("include/"));
    modules.scg.addSystemIncludePath(b.path("libscg/"));
    modules.scg.addCMacro("SCHILY_BUILD", "");
    modules.scg.addCMacro("USE_PG", "");
    modules.scg.addCMacro("SCHILY_PRINT", "");
    modules.scg.addCMacro("_GNU_SOURCE", "");
    const lib_scg = b.addLibrary(.{
        .name = "scg",
        .root_module = modules.scg,
        .linkage = .static,
    });

    modules.rscg.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.rscg.addSystemIncludePath(b.path("include/"));
    modules.rscg.addSystemIncludePath(b.path("libscg/"));
    modules.rscg.addCMacro("SCHILY_BUILD", "");
    modules.rscg.addCMacro("USE_PG", "");
    modules.rscg.addCMacro("USE_RCMD_RSH", "");
    modules.rscg.addCMacro("SCHILY_PRINT", "");
    modules.rscg.addCMacro("_GNU_SOURCE", "");
    const lib_rscg = b.addLibrary(.{
        .name = "rscg",
        .root_module = modules.rscg,
        .linkage = .static,
    });

    modules.cdrdeflt.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.cdrdeflt.addSystemIncludePath(b.path("include/"));
    modules.cdrdeflt.addSystemIncludePath(b.path("libcdrdeflt/"));
    modules.cdrdeflt.addCMacro("SCHILY_BUILD", "");
    modules.cdrdeflt.addCMacro("_GNU_SOURCE", "");
    const lib_cdrdeflt = b.addLibrary(.{
        .name = "cdrdeflt",
        .root_module = modules.cdrdeflt,
        .linkage = .static,
    });

    modules.deflt.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.deflt.addSystemIncludePath(b.path("include/"));
    modules.deflt.addCMacro("SCHILY_BUILD", "");
    modules.deflt.addCMacro("_GNU_SOURCE", "");
    const lib_deflt = b.addLibrary(.{
        .name = "deflt",
        .root_module = modules.deflt,
        .linkage = .static,
    });

    modules.mdigest.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.mdigest.addSystemIncludePath(b.path("include/"));
    modules.mdigest.addCMacro("SCHILY_BUILD", "");
    modules.mdigest.addCMacro("USE_PG", "");
    modules.mdigest.addCMacro("SHA2_UNROLL_TRANSFORM", "");
    modules.mdigest.addCMacro("_GNU_SOURCE", "");
    const lib_mdigest = b.addLibrary(.{
        .name = "mdigest",
        .root_module = modules.mdigest,
        .linkage = .static,
    });

    modules.mkisofs.linkLibrary(lib_hfs_iso);
    modules.mkisofs.linkLibrary(lib_schily);
    modules.mkisofs.linkLibrary(lib_find);
    modules.mkisofs.linkLibrary(lib_siconv);
    modules.mkisofs.linkLibrary(lib_scgcmd);
    modules.mkisofs.linkLibrary(lib_file);
    modules.mkisofs.linkLibrary(lib_scg);
    modules.mkisofs.linkLibrary(lib_rscg);
    modules.mkisofs.linkLibrary(lib_cdrdeflt);
    modules.mkisofs.linkLibrary(lib_deflt);
    modules.mkisofs.linkLibrary(lib_mdigest);
    modules.mkisofs.addSystemIncludePath(b.path("incs/x86_64-linux-gcc/"));
    modules.mkisofs.addSystemIncludePath(b.path("include/"));
    modules.mkisofs.addSystemIncludePath(b.path("libscg/"));
    modules.mkisofs.addSystemIncludePath(b.path("libscgcmd/"));
    modules.mkisofs.addSystemIncludePath(b.path("libcdrdeflt/"));
    modules.mkisofs.addSystemIncludePath(b.path("libhfs_iso/"));
    modules.mkisofs.addCMacro("SCHILY_BUILD", "");
    modules.mkisofs.addCMacro("USE_FIND", "");
    modules.mkisofs.addCMacro("USE_LARGEFILES", "");
    modules.mkisofs.addCMacro("APPLE_HFS_HYB", "");
    modules.mkisofs.addCMacro("APPLE_HYB", "");
    modules.mkisofs.addCMacro("UDF", "");
    modules.mkisofs.addCMacro("DVD_AUD_VID", "");
    modules.mkisofs.addCMacro("SORTING", "");
    modules.mkisofs.addCMacro("DUPLICATES_ONCE", "");
    modules.mkisofs.addCMacro("USE_SCG", "");
    modules.mkisofs.addCMacro("SCHILY_PRINT", "");
    modules.mkisofs.addCMacro("USE_NLS", "");
    modules.mkisofs.addCMacro("USE_ICONV", "");
    modules.mkisofs.addCMacro("_GNU_SOURCE", "");
    modules.mkisofs.addCMacro("APPID_DEFAULT", "\"MKISOFS ISO9660/HFS/UDF FILESYSTEM BUILDER & CDRECORD CD/DVD/BluRay CREATOR (C) 1993 E.YOUNGDALE (C) 1997 J.PEARSON/J.SCHILLING\"");
    modules.mkisofs.addCMacro("INS_BASE", "\"/opt/schily\"");
    modules.mkisofs.addCMacro("TEXT_DOMAIN", "\"SCHILY_cdrtools\"");

    const bins: Binaries = .{
        .hfs_iso = lib_hfs_iso,
        .mkisofs = b.addExecutable(.{
            .name = "mkisofs",
            .root_module = modules.mkisofs,
            .linkage = .static,
        }),
        .schily = lib_schily,
        .find = lib_find,
        .siconv = lib_siconv,
        .scgcmd = lib_scgcmd,
        .file = lib_file,
        .scg = lib_scg,
        .rscg = lib_rscg,
        .cdrdeflt = lib_cdrdeflt,
        .deflt = lib_deflt,
        .mdigest = lib_mdigest,
    };

    BuildSteps.createSteps(b, &bins);
}
