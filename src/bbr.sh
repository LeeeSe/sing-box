_open_bbr() {
	# 确保 sysctl.d 目录存在
	[[ ! -d /etc/sysctl.d ]] && mkdir -p /etc/sysctl.d

	# 创建 BBR 配置文件
	cat > /etc/sysctl.d/99-bbr.conf << EOF
# BBR 优化配置
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF

	# 同时处理传统的 sysctl.conf (如果存在)
	if [[ -f /etc/sysctl.conf ]]; then
		sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
		sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
		echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
		echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
	fi

	# 应用配置
	sysctl -p /etc/sysctl.d/99-bbr.conf &>/dev/null
	[[ -f /etc/sysctl.conf ]] && sysctl -p &>/dev/null
	echo
	_green "..已经启用 BBR 优化...."
	echo
}

_try_enable_bbr() {
	local _test1=$(uname -r | cut -d\. -f1)
	local _test2=$(uname -r | cut -d\. -f2)
	if [[ $_test1 -eq 4 && $_test2 -ge 9 ]] || [[ $_test1 -ge 5 ]]; then
		_open_bbr
	else
		err "不支持启用 BBR 优化."
	fi
}
