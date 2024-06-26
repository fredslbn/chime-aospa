// SPDX-License-Identifier: GPL-2.0
/* Copyright (c) 2020 Facebook */
#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char _license[] SEC("license") = "GPL";

SEC("iter/task_file")
int dump_task_file(struct bpf_iter__task_file *ctx)
{
	struct seq_file *seq = ctx->meta->seq;
	struct task_struct *task = ctx->task;
	__u32 fd = ctx->fd;
	struct file *file = ctx->file;

	if (task == (void *)0 || file == (void *)0)
		return 0;

	if (ctx->meta->seq_num == 0)
		BPF_SEQ_PRINTF(seq, "    tgid      gid       fd      file\n");

	BPF_SEQ_PRINTF(seq, "%8d %8d %8d %lx\n", task->tgid, task->pid, fd,
		       (long)file->f_op);
	return 0;
}
