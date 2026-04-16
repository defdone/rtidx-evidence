import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { CoinsIcon, HistoryIcon, BuildingIcon, SettingsIcon, LogOutIcon } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { useWallet } from '../context/WalletContext';
import { userPortfolio } from '../utils/mockData';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function User() {
  const { address, disconnectWallet } = useWallet();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('portfolio');

  const tabs = [
    { id: 'portfolio', label: 'My Portfolio', icon: <BuildingIcon size={18} /> },
    { id: 'transactions', label: 'Transactions', icon: <HistoryIcon size={18} /> },
    { id: 'settings', label: 'Settings', icon: <SettingsIcon size={18} /> },
  ];

  const transactions = [
    { id: 1, type: 'purchase', property: 'Luxury Downtown Apartment', tokens: 2, value: 1.0, date: '2023-06-15' },
    { id: 2, type: 'purchase', property: 'Beachfront Villa', tokens: 1, value: 1.2, date: '2023-05-22' },
    { id: 3, type: 'dividend', property: 'Luxury Downtown Apartment', tokens: 0, value: 0.05, date: '2023-04-01' },
    { id: 4, type: 'purchase', property: 'Urban Retail Space', tokens: 1, value: 0.67, date: '2023-03-10' },
  ];

  return (
    <div className="min-h-screen w-full">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14 lg:py-20">
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.5 }}>
          <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 mb-10">
            <div>
              <h1 className="font-display text-3xl md:text-4xl font-bold text-cream-100 mb-2">
                My Dashboard
              </h1>
              <div className="flex items-center gap-3">
                <span className="px-3 py-1.5 rounded-lg bg-void-700 border border-void-600 text-cream-300 text-sm font-mono">
                  {address?.slice(0, 6)}...{address?.slice(-4)}
                </span>
              </div>
            </div>
            <div className="flex gap-2 [&_button]:!rounded-lg">
              <ConnectButton />
              <Button variant="outline" icon={<LogOutIcon size={18} />} onClick={() => disconnectWallet()}>
                Disconnect
              </Button>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
            {[
              { icon: BuildingIcon, label: 'Properties owned', value: userPortfolio.totalProperties },
              { icon: CoinsIcon, label: 'Total invested', value: `${userPortfolio.totalInvested} ETH`, accent: true },
              { icon: HistoryIcon, label: 'Last activity', value: '3 days ago' },
            ].map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.1 }}
                className="p-6 rounded-2xl border border-void-700 bg-void-800/60"
              >
                <div className="flex items-center gap-2 text-cream-400 text-sm mb-2">
                  <stat.icon size={16} />
                  {stat.label}
                </div>
                <div className={`font-display text-2xl font-bold ${stat.accent ? 'text-accent' : 'text-cream-100'}`}>
                  {stat.value}
                </div>
              </motion.div>
            ))}
          </div>

          <div className="rounded-2xl border border-void-700 bg-void-800/40 overflow-hidden">
            <nav className="flex border-b border-void-700">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-6 py-4 flex items-center gap-2 text-sm font-medium transition-colors ${
                    activeTab === tab.id
                      ? 'text-accent border-b-2 border-accent bg-accent-muted/30'
                      : 'text-cream-400 hover:text-cream-100'
                  }`}
                >
                  {tab.icon}
                  {tab.label}
                </button>
              ))}
            </nav>
            <div className="p-6">
              {activeTab === 'portfolio' && (
                <div>
                  <h3 className="font-display text-lg font-semibold text-cream-100 mb-6">My properties</h3>
                  <div className="overflow-x-auto rounded-xl border border-void-700">
                    <table className="min-w-full">
                      <thead>
                        <tr className="border-b border-void-700">
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Property</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Tokens</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Value</th>
                          <th className="px-6 py-3 text-right text-xs font-medium text-cream-400 uppercase tracking-wider">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-void-700">
                        {userPortfolio.properties.map((p) => (
                          <tr key={p.propertyId} className="hover:bg-void-700/30 transition-colors">
                            <td className="px-6 py-4 text-cream-100 font-medium">{p.propertyName}</td>
                            <td className="px-6 py-4 text-cream-400">{p.tokensOwned}</td>
                            <td className="px-6 py-4 text-accent">{p.investmentValue} ETH</td>
                            <td className="px-6 py-4 text-right">
                              <Button variant="outline" size="sm" onClick={() => navigate(`/property/${p.propertyId}`)}>
                                View
                              </Button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
              {activeTab === 'transactions' && (
                <div>
                  <h3 className="font-display text-lg font-semibold text-cream-100 mb-6">Transaction history</h3>
                  <div className="overflow-x-auto rounded-xl border border-void-700">
                    <table className="min-w-full">
                      <thead>
                        <tr className="border-b border-void-700">
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Date</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Type</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Property</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-cream-400 uppercase tracking-wider">Amount</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-void-700">
                        {transactions.map((tx) => (
                          <tr key={tx.id} className="hover:bg-void-700/30 transition-colors">
                            <td className="px-6 py-4 text-cream-400">{tx.date}</td>
                            <td className="px-6 py-4">
                              <Badge color={tx.type === 'purchase' ? 'accent' : 'green'}>{tx.type === 'purchase' ? 'Purchase' : 'Dividend'}</Badge>
                            </td>
                            <td className="px-6 py-4 text-cream-100">{tx.property}</td>
                            <td className="px-6 py-4 text-accent">{tx.value} ETH {tx.tokens > 0 && `(${tx.tokens} tokens)`}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
              {activeTab === 'settings' && (
                <div>
                  <h3 className="font-display text-lg font-semibold text-cream-100 mb-6">Account settings</h3>
                  <div className="space-y-6 max-w-lg">
                    <div>
                      <h4 className="text-cream-100 font-medium mb-3">Notifications</h4>
                      <div className="space-y-2">
                        <label className="flex items-center gap-3 cursor-pointer">
                          <input type="checkbox" defaultChecked className="rounded border-void-600 bg-void-700 text-accent focus:ring-accent/50" />
                          <span className="text-cream-400">New properties</span>
                        </label>
                        <label className="flex items-center gap-3 cursor-pointer">
                          <input type="checkbox" defaultChecked className="rounded border-void-600 bg-void-700 text-accent focus:ring-accent/50" />
                          <span className="text-cream-400">Dividend payments</span>
                        </label>
                      </div>
                    </div>
                    <div>
                      <h4 className="text-cream-100 font-medium mb-2">Connected wallet</h4>
                      <div className="p-4 rounded-xl bg-void-700/50 border border-void-600">
                        <div className="flex items-center justify-between gap-4">
                          <div>
                            <div className="text-cream-100 font-medium">Wallet</div>
                            <div className="text-cream-400 text-sm font-mono truncate">{address}</div>
                          </div>
                          <ConnectButton />
                        </div>
                      </div>
                    </div>
                    <Button>Save settings</Button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
