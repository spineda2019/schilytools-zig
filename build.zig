const std = @import("std");

const SourceFile = struct {
    name: []const u8,
    directory: []const u8,
};

const Modules = struct {
    hfs_iso: *std.Build.Module,
    mkisofs: *std.Build.Module,

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
};

const Binaries = struct {
    hfs_iso: *std.Build.Step.Compile,
    mkisofs: *std.Build.Step.Compile,
};

const BuildSteps = struct {
    hfs_iso: *std.Build.Step,
    mkisofs: *std.Build.Step,

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

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    const modules: Modules = .init(b);

    const mod_hfs_iso_files = comptime [_]SourceFile{
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
    };
    const hfs_iso_flags = comptime [_][]const u8{"-M"};
    inline for (mod_hfs_iso_files) |file| {
        const lp = b.path(file.directory).join(b.allocator, file.name) catch @panic("OOM");
        modules.hfs_iso.addCSourceFile(.{
            .language = .c,
            .file = lp,
            .flags = hfs_iso_flags[0..],
        });
    }
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

    const mkisofs_files = comptime [_]SourceFile{
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
    };
    const flags = comptime [_][]const u8{};
    inline for (mkisofs_files) |file| {
        const lp = b.path(file.directory).join(b.allocator, file.name) catch @panic("OOM");
        modules.mkisofs.addCSourceFile(.{
            .language = .c,
            .file = lp,
            .flags = flags[0..],
        });
    }
    modules.mkisofs.linkLibrary(lib_hfs_iso);
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
    };

    BuildSteps.createSteps(b, &bins);
}
